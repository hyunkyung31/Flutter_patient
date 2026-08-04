import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patient_app/core/storage/secure_storage.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/auth/data/local/biometric_service.dart';

import '../../../home/view/main_shell_page.dart';
import 'login_page.dart';

/// Intro splash
/// - vena / heart: 고정
/// - ECG: 왼쪽 → 오른쪽으로 그려지며 반복
/// - 토큰 + 자동로그인(+생체) 있으면 홈으로, 아니면 로그인
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _ecgController;
  late final AnimationController _progressController;
  late final AnimationController _fadeController;
  Timer? _navTimer;
  bool _navigated = false;

  final _biometric = BiometricService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _navTimer = Timer(const Duration(milliseconds: 2500), _bootstrap);
  }

  Future<void> _bootstrap() async {
    if (!mounted || _navigated) return;

    try {
      final hasTokens = await SecureStorageService.hasTokens();
      final autoLogin = await SecureStorageService.isAutoLoginEnabled();

      if (!hasTokens || !autoLogin) {
        _goLogin();
        return;
      }

      final biometricOn = await SecureStorageService.isBiometricEnabled();
      if (biometricOn) {
        final canBio = await _biometric.canCheckBiometrics();
        if (canBio) {
          final ok = await _biometric.authenticate(
            reason: '자동로그인을 위해 생체인증을 진행합니다.',
          );
          if (!ok) {
            // 실패 시 로그인 화면으로 (토큰은 유지 → 설정에서 다시 시도 가능)
            _goLogin();
            return;
          }
        }
      }

      final name = await SecureStorageService.getPatientName();
      final patientId = await SecureStorageService.getPatientId();
      _goHome(patientName: name, patientId: patientId);
    } catch (_) {
      _goLogin();
    }
  }

  void _goLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _goHome({String? patientName, String? patientId}) {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainShellPage(
          patientName: patientName,
          patientId: patientId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ecgController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// 0~0.75 그려짐 / 0.75~1.0 유지
  double _drawProgress(double t) {
    if (t <= 0.75) {
      return Curves.easeInOut.transform(t / 0.75);
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeController,
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/vena_text.png',
                          height: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Text(
                            'vena',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _ecgController,
                          builder: (context, _) {
                            final draw = _drawProgress(_ecgController.value);
                            final heartOpacity = Curves.easeOut.transform(
                              ((draw - 0.85) / 0.15).clamp(0.0, 1.0),
                            );

                            return SizedBox(
                              width: 240,
                              height: 44,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: draw,
                                        child: Image.asset(
                                          'assets/images/ecg_line.png',
                                          height: 36,
                                          width: 200,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.centerLeft,
                                          errorBuilder: (_, __, ___) {
                                            return CustomPaint(
                                              size: const Size(200, 36),
                                              painter: _FallbackEcgPainter(
                                                progress: draw,
                                                color: AppColors.accent,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Opacity(
                                    opacity: heartOpacity,
                                    child: Image.asset(
                                      'assets/images/heart.png',
                                      height: 22,
                                      width: 22,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(
                                        Icons.favorite_rounded,
                                        size: 22,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'AI가 심혈관 건강을\n더 정확하고 안전하게',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 4),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 6,
                            backgroundColor: AppColors.lightBlue,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.secondary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
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

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

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

class _FallbackEcgPainter extends CustomPainter {
  final double progress;
  final Color color;

  _FallbackEcgPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final y = size.height * 0.55;
    final path = Path()
      ..moveTo(0, y)
      ..lineTo(size.width * 0.18, y)
      ..lineTo(size.width * 0.28, size.height * 0.35)
      ..lineTo(size.width * 0.40, size.height * 0.08)
      ..lineTo(size.width * 0.52, size.height * 0.92)
      ..lineTo(size.width * 0.62, y)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.28,
        size.width * 0.82,
        y,
      )
      ..lineTo(size.width, y);

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FallbackEcgPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
