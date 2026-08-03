import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/kakao_login_button.dart';
import '../../data/datasource/kakao_auth_service.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoAuthService _authService = KakaoAuthService();
  bool _isLoading = false;

  Future<void> _onKakaoLoginPressed() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.loginWithKakao();

      if (!mounted) return;

      // 신규 회원
      if (result.isNewUser) {
        final signupToken = result.signupToken;
        if (signupToken == null || signupToken.isEmpty) {
          _showLoginError('회원가입 토큰이 없습니다. 서버 응답을 확인해주세요.');
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupPage(signupToken: signupToken),
          ),
        );
        return;
      }

      // 기존 회원
      await SecureStorageService.saveToken(
        access: result.access,
        refresh: result.refresh,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 성공')));

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => const HomePage(),
      //   ),
      // );
    } on PlatformException catch (e) {
      if (!mounted || e.code == 'CANCELED') return;
      _showLoginError('카카오 로그인 실패\ncode=${e.code}\n${e.message}');
    } catch (e) {
      if (!mounted) return;
      _showLoginError(_userFacingMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _userFacingMessage(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '');
    if (raw.isEmpty) {
      return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
    return raw;
  }

  void _showLoginError(String message) {
    debugPrint('Login error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.favorite, size: 90, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'AI 기반 심혈관 건강관리',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 80),
              KakaoLoginButton(
                onPressed: _isLoading ? null : _onKakaoLoginPressed,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
