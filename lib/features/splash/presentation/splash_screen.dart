import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/data/local/biometric_service.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../home/view/main_shell_page.dart';
import '../../onboarding/data/onboarding_storage.dart';
import '../../onboarding/presentation/bomi_onboarding_screen.dart';

/// VENA 브랜드 스플래시
///
/// assets:
/// - assets/images/splash_vena_white.png
/// - assets/images/bomi_peek.png
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color dustyRose = Color(0xFFC9939D);
  static const Color onRose = Colors.white;

  late final AnimationController _enter;
  late final AnimationController _progress;

  late final Animation<double> _fadeIn;
  late final Animation<double> _logoScale;
  late final Animation<double> _bomiOpacity;

  bool _navigated = false;
  final _biometric = BiometricService();

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: dustyRose,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _enter, curve: Curves.easeOut);

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _bomiOpacity = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
    );

    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _enter.forward();
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _progress.forward();
    });

    _progress.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goNext();
      }
    });
  }

  Future<void> _goNext() async {
    if (!mounted || _navigated) return;

    try {
      // 디버그 실행에서는 시연을 위해 온보딩 완료 기록 초기화
      if (kDebugMode) {
        await OnboardingStorage.reset();
      }

      final bool onboardingCompleted = await OnboardingStorage.isCompleted();

      debugPrint('Splash onboarding completed: $onboardingCompleted');

      if (!mounted || _navigated) return;

      // 온보딩을 아직 완료하지 않았다면 온보딩 화면으로 이동
      if (!onboardingCompleted) {
        _navigated = true;

        Navigator.of(
          context,
        ).pushReplacement(_fadeRoute(const BomiOnboardingScreen()));
        return;
      }

      // 최신 main에 추가된 로그인 세션 확인 코드 유지
      final summary = await SecureStorageService.debugSessionSummary();

      debugPrint('Splash session: $summary');

      final bool hasTokens = await SecureStorageService.hasTokens();

      final bool autoLogin = await SecureStorageService.isAutoLoginEnabled();

      if (hasTokens && autoLogin) {
        final bool biometricOn =
            await SecureStorageService.isBiometricEnabled();

        if (biometricOn) {
          final bool canBio = await _biometric.canCheckBiometrics();

          if (canBio) {
            final bool ok = await _biometric.authenticate(
              reason: '자동로그인을 위해 생체인증을 진행합니다.',
            );

            if (!ok) {
              debugPrint('Splash: biometric failed → login');
              _openLogin();
              return;
            }
          }
        }

        final String? name = await SecureStorageService.getPatientName();

        final String? patientId = await SecureStorageService.getPatientId();

        if (!mounted || _navigated) return;

        _navigated = true;

        Navigator.of(context).pushReplacement(
          _fadeRoute(MainShellPage(patientName: name, patientId: patientId)),
        );
        return;
      }

      debugPrint(
        'Splash: skip auto-login '
        '(hasTokens=$hasTokens autoLogin=$autoLogin)',
      );
    } catch (error, stackTrace) {
      debugPrint('Splash onboarding/auto-login error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    _openLogin();
  }

  void _openLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(_fadeRoute(const LoginPage()));
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // 현재 작업 중인 에뮬레이터 크기를 기준으로 한 반응형 배율
    final widthScale = (size.width / 393).clamp(0.90, 1.10);
    final heightScale = (size.height / 852).clamp(0.90, 1.10);
    final textScale = widthScale;

    return Scaffold(
      backgroundColor: dustyRose,
      body: AnimatedBuilder(
        animation: Listenable.merge([_enter, _progress]),
        builder: (context, _) {
          return Stack(
            children: [
              // 1) 중앙: 슬로건 + 로고 + 로딩바
              Positioned(
                top: size.height * 0.335,
                left: 24 * widthScale,
                right: 24 * widthScale,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '건강한 오늘이 더 좋은 내일로 이어지도록',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: onRose,
                          fontSize: 19 * textScale,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                      ),

                      SizedBox(height: 30 * heightScale),

                      Transform.scale(
                        scale: _logoScale.value,
                        child: Image.asset(
                          'assets/images/splash_vena_white.png',
                          width: size.width * 0.62,
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: 36 * heightScale),

                      _LoadingBar(
                        progress: _progress.value,
                        width: size.width * 0.64,
                        heightScale: heightScale,
                      ),
                    ],
                  ),
                ),
              ),

              // 2) 우측 하단 보미 (크게 + 구석으로 자름)
              Positioned(
                right: -180 * widthScale,
                bottom: -50 * heightScale,
                child: FadeTransition(
                  opacity: _bomiOpacity,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: -0.2,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/bomi_peek.png',
                        width: size.width * 1.08,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // 3) 하단 영문 + 버전
              Positioned(
                left: 24 * widthScale,
                right: 24 * widthScale,
                bottom: bottomInset + (34 * heightScale),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Connecting hearts, simplifying health.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xF2FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'v.1.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.progress,
    required this.width,
    required this.heightScale,
  });

  final double progress;
  final double width;
  final double heightScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 20 * heightScale,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.all(4 * heightScale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.white.withOpacity(0.28)),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
