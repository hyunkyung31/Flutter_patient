import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../../home/view/main_shell_page.dart';
import '../../data/datasource/kakao_auth_service.dart';
import '../widgets/kakao_login_button.dart';
import 'signup_page.dart';

/// 환자 카카오 로그인 화면 (의료진 LoginScreen 톤에 맞춤)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoAuthService _authService = KakaoAuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _onKakaoLoginPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.loginWithKakao();
      if (!mounted) return;

      // 신규 회원 → 회원가입 화면
      if (result.needsSignup) {
        final signupToken = result.signupToken;
        if (signupToken == null || signupToken.isEmpty) {
          setState(() {
            _errorMessage =
                '회원가입이 필요하지만 signup_token이 없습니다.\n서버 응답을 확인해주세요.';
          });
          return;
        }

        debugPrint('Login → SignupPage (signupToken exists)');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignupPage(signupToken: signupToken),
          ),
        );
        return;
      }

      if (result.access.isEmpty || result.refresh.isEmpty) {
        setState(() {
          _errorMessage = '로그인 토큰이 없습니다. 서버 응답을 확인해주세요.';
        });
        return;
      }

      // 기존 회원 → 토큰/프로필 저장 후 홈 (자동로그인 기본 ON)
      await SecureStorageService.saveSession(
        access: result.access,
        refresh: result.refresh,
        patientId: result.patientId,
        patientName: result.patientName,
        enableAutoLogin: true,
      );
      if (!mounted) return;

      debugPrint(
        'Login OK → MainShell '
        'patient=${result.patientName}, id=${result.patientId}, '
        'accessLen=${result.access.length}',
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainShellPage(
            patientName: result.patientName,
            patientId: result.patientId,
          ),
        ),
        (_) => false,
      );
    } on PlatformException catch (e) {
      // 카카오 창 닫기/취소는 에러로 보여주지 않음
      if (!mounted || e.code == 'CANCELED') return;
      setState(() {
        _errorMessage = '카카오 로그인 실패\ncode=${e.code}\n${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('CANCELED') || msg.contains('User canceled login')) {
        return;
      }
      setState(() {
        _errorMessage = _userFacingMessage(e);
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _userFacingMessage(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '');
    if (raw.isEmpty) {
      return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 22 : 30,
                            vertical: isCompact ? 26 : 34,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.lightBlue),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x141E3A8A),
                                blurRadius: 28,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _LoginHeader(),
                              const SizedBox(height: 28),
                              if (_errorMessage != null) ...[
                                _LoginMessage(message: _errorMessage!),
                                const SizedBox(height: 16),
                              ],
                              KakaoLoginButton(
                                onPressed:
                                    _isLoading ? null : _onKakaoLoginPressed,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 20),
                              const _SecurityNotice(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/vena_login_logo.png',
          height: 88,
          fit: BoxFit.contain,
          semanticLabel: 'VENA',
          errorBuilder: (_, __, ___) {
            return Image.asset(
              'assets/images/brand/vena_logo.png',
              height: 88,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/brand/vena_text.png',
                height: 56,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'vena',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Text(
                '환자 전용',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'VENA - Patient',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 20,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '카카오 계정으로\n심혈관 건강 관리 서비스를 이용할 수 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _LoginMessage extends StatelessWidget {
  const _LoginMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: Color(0xFFB91C1C),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityNotice extends StatelessWidget {
  const _SecurityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 15,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '로그인 정보는 기기의 보안 저장소에\n안전하게 보관됩니다.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.background,
                Color(0xFFF0F7FF),
                AppColors.lightBlue,
              ],
              stops: [0.0, 0.58, 1.0],
            ),
          ),
          child: SizedBox.expand(),
        ),
        Positioned(
          top: -90,
          right: -70,
          child: Container(
            width: 230,
            height: 230,
            decoration: const BoxDecoration(
              color: Color(0x183B82F6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0x1FF59CB3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}