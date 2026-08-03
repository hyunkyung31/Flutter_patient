import 'package:flutter/material.dart';
import 'package:patient_app/core/storage/secure_storage.dart';

import '../../data/datasource/kakao_auth_service.dart';

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

  @override
  void dispose() {
    _phoneController.dispose();
    _birthController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final phone = _phoneController.text.trim();
    final birthDate = _birthController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }

    if (phone.isEmpty || birthDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호와 생년월일을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signupWithKakao(
        signupToken: widget.signupToken,
        phone: phone, // service에서 숫자만 정규화
        birthDate: birthDate,
        name: name,
      );

      await SecureStorageService.saveToken(
        access: result.access,
        refresh: result.refresh,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 및 로그인 성공')),
      );

      // TODO: 홈으로 이동
      // Navigator.pushReplacement(... HomePage ...);
      Navigator.pop(context); // 임시: 로그인 화면으로 복귀
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
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
                decoration: const InputDecoration(
                  labelText: '이름 (선택)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '01012345678',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  hintText: '900101',
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