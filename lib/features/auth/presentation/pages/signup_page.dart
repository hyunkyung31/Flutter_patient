import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patient_app/core/storage/secure_storage.dart';

import '../../data/datasource/kakao_auth_service.dart';
import '../../../home/view/main_shell_page.dart';

class SignupPage extends StatefulWidget {
  final String signupToken;

  const SignupPage({
    super.key,
    required this.signupToken,
  });

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = KakaoAuthService();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _phoneController.dispose();
    _birthController.dispose();
    _nameController.dispose();
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
    return '$y-$m-$d'; // 서버로 보낼 형식 (원하면 yyMMdd로 바꿔도 됨)
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

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }

    if (phoneDigits.length != 11 || !phoneDigits.startsWith('010')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호는 010 - ____ - ____ 형식으로 입력해주세요.')),
      );
      return;
    }

    if (birthDate.isEmpty || _selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signupWithKakao(
        signupToken: widget.signupToken,
        phone: phoneDigits, // 서버에는 숫자만: 01012345678
        birthDate: birthDate, // 예: 1990-01-01
        name: name, // 필수
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '이름', // (선택) 제거
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
                    selection: TextSelection.collapsed(offset: formatted.length),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('가입 완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
