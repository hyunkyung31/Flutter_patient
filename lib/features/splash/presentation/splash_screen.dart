import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/data/local/biometric_service.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../home/view/main_shell_page.dart';

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

    _fadeIn = CurvedAnimation(
      parent: _enter,
      curve: Curves.easeOut,
    );

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
      final summary = await SecureStorageService.debugSessionSummary();
      debugPrint('Splash session: $summary');

      final hasTokens = await SecureStorageService.hasTokens();
      final autoLogin = await SecureStorageService.isAutoLoginEnabled();

      if (hasTokens && autoLogin) {
        final biometricOn = await SecureStorageService.isBiometricEnabled();
        if (biometricOn) {
          final canBio = await _biometric.canCheckBiometrics();
          if (canBio) {
            final ok = await _biometric.authenticate(
              reason: '자동로그인을 위해 생체인증을 진행합니다.',
            );
            if (!ok) {
              debugPrint('Splash: biometric failed → login');
              _openLogin();
              return;
            }
          } else {
            debugPrint(
              'Splash: biometric enabled but device cannot check → skip bio',
            );
          }
        }

        final name = await SecureStorageService.getPatientName();
        final patientId = await SecureStorageService.getPatientId();
        if (!mounted || _navigated) return;
        _navigated = true;
        Navigator.of(context).pushReplacement(
          _fadeRoute(
            MainShellPage(
              patientName: name,
              patientId: patientId,
            ),
          ),
        );
        return;
      }

      debugPrint(
        'Splash: skip auto-login (hasTokens=$hasTokens autoLogin=$autoLogin)',
      );
    } catch (e) {
      debugPrint('Splash auto-login error: $e');
    }

    _openLogin();
  }

  void _openLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      _fadeRoute(const LoginPage()),
    );
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

    // 캐릭터 크게 + 모서리로 많이 잘리게 (까꿍)
    final bomiH = (size.height * 0.40).clamp(250.0, 350.0);

    return Scaffold(
      backgroundColor: dustyRose,
      body: AnimatedBuilder(
        animation: Listenable.merge([_enter, _progress]),
        builder: (context, _) {
          return Stack(
            children: [
              // 1) 중앙: 슬로건 + 로고 + 로딩바
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Align(
                    alignment: const Alignment(0, -0.35),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '건강한 오늘이 더 좋은 내일로 이어지도록',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: onRose,
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              'assets/images/splash_vena_white.png',
                              width: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _LoadingBar(progress: _progress.value),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2) 우측 하단 보미 (크게 + 구석으로 자름)
              Positioned(
                right: -50,
                bottom: -40,
                child: Opacity(
                  opacity: _bomiOpacity.value,
                  child: Image.asset(
                    'assets/images/bomi_peek.png',
                    height: bomiH,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 3) 하단 영문 + 버전
              Positioned(
                left: 24,
                right: 24,
                bottom: bottomInset + 16,
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
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.35),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
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