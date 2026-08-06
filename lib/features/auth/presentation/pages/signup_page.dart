import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../data/datasource/kakao_auth_service.dart';
import '../../../home/view/main_shell_page.dart';

/// 병원 등록 환자 회원가입
/// - [signupToken] 있으면: 카카오 연동 가입
/// - 없으면: 아이디/비밀번호 가입
class SignupPage extends StatefulWidget {
  final String? signupToken;

  const SignupPage({
    super.key,
    this.signupToken,
  });

  bool get isKakaoLink =>
      signupToken != null && signupToken!.trim().isNotEmpty;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = KakaoAuthService();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _selectedBirthDate;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _birthController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String _digitsOnly(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

  String _formatPhone(String raw) {
    final digits = _digitsOnly(raw);
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)} - ${digits.substring(3)}';
    }
    final end = digits.length > 11 ? 11 : digits.length;
    return '${digits.substring(0, 3)} - ${digits.substring(3, 7)} - ${digits.substring(7, end)}';
  }

  String _formatBirth(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1920, 1, 1),
      lastDate: now,
      helpText: '생년월일 선택',
      cancelText: '취소',
      confirmText: '확인',
    );

    if (picked == null) return;

    setState(() {
      _selectedBirthDate = picked;
      _birthController.text = _formatBirth(picked);
    });
  }

  Future<void> _onSubmit() async {
    final name = _nameController.text.trim();
    final phoneDigits = _digitsOnly(_phoneController.text);
    final birthDate = _birthController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final username = _usernameController.text.trim();

    setState(() => _errorMessage = null);

    if (name.isEmpty) {
      setState(() => _errorMessage = '이름을 입력해주세요.');
      return;
    }

    if (phoneDigits.length != 11 || !phoneDigits.startsWith('010')) {
      setState(() =>
          _errorMessage = '전화번호는 010 - ____ - ____ 형식으로 입력해주세요.');
      return;
    }

    if (birthDate.isEmpty || _selectedBirthDate == null) {
      setState(() => _errorMessage = '생년월일을 선택해주세요.');
      return;
    }

    if (!widget.isKakaoLink) {
      if (username.length < 3) {
        setState(() => _errorMessage = '아이디는 3자 이상 입력해주세요.');
        return;
      }
      if (password.length < 4) {
        setState(() => _errorMessage = '비밀번호는 4자 이상이어야 합니다.');
        return;
      }
      if (password != passwordConfirm) {
        setState(() => _errorMessage = '비밀번호 확인이 일치하지 않습니다.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final result = widget.isKakaoLink
          ? await _authService.signupWithKakao(
              signupToken: widget.signupToken!,
              phone: phoneDigits,
              birthDate: birthDate,
              name: name,
            )
          : await _authService.signupWithPassword(
              name: name,
              phone: phoneDigits,
              birthDate: birthDate,
              password: password,
              username: username,
            );

      if (result.access.isEmpty || result.refresh.isEmpty) {
        throw Exception('회원가입 응답에 토큰이 없습니다.');
      }

      await SecureStorageService.saveSession(
        access: result.access,
        refresh: result.refresh,
        patientId: result.patientId,
        patientName: result.patientName ?? name,
        enableAutoLogin: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 및 로그인 성공')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainShellPage(
            patientName: result.patientName ?? name,
            patientId: result.patientId,
          ),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isKakaoLink ? '카카오 계정 연결' : '병원 환자 회원가입';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              widget.isKakaoLink
                  ? '병원에 등록된 이름·연락처로 본인 확인 후\n카카오 계정을 연결합니다.'
                  : '병원에 등록된 환자만 가입할 수 있습니다.\n이름·생년월일·연락처로 본인 확인 후\n아이디/비밀번호를 만듭니다.',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '병원에 등록된 이름',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                final formatted = _formatPhone(value);
                _phoneController.value = TextEditingValue(
                  text: formatted,
                  selection:
                      TextSelection.collapsed(offset: formatted.length),
                );
              },
              decoration: const InputDecoration(
                labelText: '전화번호',
                hintText: '010 - ____ - ____',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthController,
              readOnly: true,
              onTap: _pickBirthDate,
              decoration: const InputDecoration(
                labelText: '생년월일',
                hintText: '달력에서 선택',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            if (!widget.isKakaoLink) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  hintText: '로그인에 사용할 아이디',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordConfirmController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onSubmit(),
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isKakaoLink ? '연결 완료' : '가입 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
