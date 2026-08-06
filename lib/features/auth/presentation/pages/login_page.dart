import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/auth/data/local/biometric_service.dart';

import '../../../home/view/main_shell_page.dart';
import '../../data/datasource/kakao_auth_service.dart';
import '../../data/model/login_response.dart';
import '../widgets/kakao_login_button.dart';
import 'signup_page.dart';

/// 환자 로그인: 아이디/비밀번호 + 카카오
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final KakaoAuthService _authService = KakaoAuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeLogin(LoginResponse result) async {
    if (result.access.isEmpty || result.refresh.isEmpty) {
      setState(() {
        _errorMessage = '로그인 토큰이 없습니다. 서버 응답을 확인해주세요.';
      });
      return;
    }

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

    await _maybeOfferBiometric();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShellPage(
          patientName: result.patientName,
          patientId: result.patientId,
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _onPasswordLoginPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.loginWithPassword(
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _completeLogin(result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _userFacingMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onKakaoLoginPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.loginWithKakao();
      if (!mounted) return;

      // 신규 회원 → 병원 환자 인증(카카오 연결) 화면
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

      await _completeLogin(result);
    } on PlatformException catch (e) {
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

  void _openHospitalSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  String _userFacingMessage(Object error) {
    final raw = error.toString().replaceFirst('Exception: ', '');
    if (raw.isEmpty) {
      return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
    return raw;
  }

  Future<void> _maybeOfferBiometric() async {
    try {
      final alreadyOn = await SecureStorageService.isBiometricEnabled();
      if (alreadyOn) return;

      final available = await BiometricService().canCheckBiometrics();
      if (!available || !mounted) return;

      final enable = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('생체 인증'),
          content: const Text(
            '다음부터 지문/Face ID로 앱을 열까요?\n'
            '(자동로그인은 유지됩니다)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('나중에'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('사용'),
            ),
          ],
        ),
      );
      if (enable == true) {
        await SecureStorageService.setBiometricEnabled(true);
      }
    } catch (e) {
      debugPrint('biometric offer skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 700;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 20 : 28,
                      vertical: isCompact ? 16 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DecoratedBox(
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 22 : 30,
                            vertical: isCompact ? 26 : 34,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _LoginHeader(),
                              const SizedBox(height: 22),
                              if (_errorMessage != null) ...[
                                _LoginMessage(message: _errorMessage!),
                                const SizedBox(height: 14),
                              ],
                              TextField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                enabled: !_isLoading,
                                decoration: const InputDecoration(
                                  labelText: '아이디 / 휴대폰번호',
                                  hintText: '가입 시 아이디 또는 010…',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                enabled: !_isLoading,
                                onSubmitted: (_) => _onPasswordLoginPressed(),
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _onPasswordLoginPressed,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          '로그인',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed:
                                    _isLoading ? null : _openHospitalSignup,
                                child: const Text(
                                  '병원 환자 회원가입',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '또는',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 12),
                              KakaoLoginButton(
                                onPressed:
                                    _isLoading ? null : _onKakaoLoginPressed,
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: 18),
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
          '병원 등록 환자만 가입할 수 있습니다.\n아이디/비밀번호 또는 카카오로 로그인하세요.',
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
