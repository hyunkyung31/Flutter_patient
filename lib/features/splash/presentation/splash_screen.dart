import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../auth/presentation/pages/login_page.dart';

/// VENA 스플래시
///
/// STEP1 로고 스케일 등장 (0.8 → 1.0)
/// STEP2 하트가 원을 돌며 **궤적 선(로딩 아크)** 이 이어짐
/// STEP3 심전도 QRS만 또렷하게 한 번 그려짐
/// STEP4 캐릭터 살짝 통통
/// STEP5 페이드아웃 → 로그인
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _orbitRadius = 92.0;
  static const _heartColor = Color(0xFFF48CA8);
  static const _accent = Color(0xFFF59CB3);

  late final AnimationController _timeline;

  late final Animation<double> _logoScale;
  late final Animation<double> _heartTurns; // 0 → 1.5
  late final Animation<double> _heartOpacity;
  late final Animation<double> _trailFade; // 궤도선 페이드아웃
  late final Animation<double> _ecgProgress;
  late final Animation<double> _bounce;
  late final Animation<double> _fadeOut;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _timeline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );

    // STEP1: 로고 등장
    _logoScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.00, 0.14, curve: Curves.easeOutBack),
      ),
    );

    // STEP2: 하트 + 궤적 선 (1.5바퀴)
    _heartTurns = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.12, 0.58, curve: Curves.easeInOutCubic),
      ),
    );
    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 78),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 14),
    ]).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.12, 0.64, curve: Curves.linear),
      ),
    );
    // 궤도선은 하트보다 조금 더 남았다가 사라짐
    _trailFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.12, 0.66, curve: Curves.linear),
      ),
    );

    // STEP3: PQRST ECG (조금 더 길게 보여줌)
    _ecgProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.56, 0.80, curve: Curves.easeInOut),
      ),
    );

    // STEP4: 통통
    _bounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.035)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.035, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 55,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.76, 0.88, curve: Curves.linear),
      ),
    );

    // STEP5: 페이드아웃
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.88, 1.00, curve: Curves.easeIn),
      ),
    );

    _timeline.forward();
    _timeline.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goLogin();
    });
  }

  void _goLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _timeline,
        builder: (context, _) {
          final turns = _heartTurns.value;
          return Opacity(
            opacity: _fadeOut.value.clamp(0.0, 1.0),
            child: Center(
              child: SizedBox(
                width: 300,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 로고
                    Transform.scale(
                      scale: _logoScale.value * _bounce.value,
                      child: Image.asset(
                        'assets/images/splash_logo.png',
                        width: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Text(
                          'vena',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: _accent,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),

                    // STEP2: 하트가 그린 원형 궤적(로딩 선)
                    if (_trailFade.value > 0.01)
                      Opacity(
                        opacity: _trailFade.value.clamp(0.0, 1.0),
                        child: CustomPaint(
                          size: const Size(300, 320),
                          painter: _OrbitTrailPainter(
                            turns: turns,
                            radius: _orbitRadius,
                            color: _heartColor,
                          ),
                        ),
                      ),

                    // STEP3: 정확한 P-QRS-T
                    Positioned(
                      bottom: 40,
                      child: Opacity(
                        opacity: _ecgProgress.value <= 0
                            ? 0
                            : (_ecgProgress.value < 1 ? 1.0 : 0.9),
                        child: CustomPaint(
                          size: const Size(220, 56),
                          painter: _PqrstEcgPainter(
                            progress: _ecgProgress.value,
                            color: _accent,
                          ),
                        ),
                      ),
                    ),

                    // STEP2: 하트
                    if (_heartOpacity.value > 0.01)
                      Opacity(
                        opacity: _heartOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: _orbitOffset(
                            turns: turns,
                            radius: _orbitRadius,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: _heartColor,
                            size: 26,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 12시에서 시계방향
  Offset _orbitOffset({required double turns, required double radius}) {
    final angle = -math.pi / 2 + (turns * 2 * math.pi);
    return Offset(radius * math.cos(angle), radius * math.sin(angle));
  }
}

/// 하트가 지나간 자리의 원호(로딩 선)
class _OrbitTrailPainter extends CustomPainter {
  _OrbitTrailPainter({
    required this.turns,
    required this.radius,
    required this.color,
  });

  final double turns;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (turns <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 옅은 가이드 원
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final sweep = turns * 2 * math.pi; // 1.5바퀴까지 계속 증가
    const start = -math.pi / 2; // 12시

    // 본선 (하트가 그린 궤적)
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // 하트 바로 뒤 짧은은 꼬리 (최근 구간 강조)
    final tailLen = math.min(sweep, math.pi * 0.35);
    if (tailLen > 0.02) {
      canvas.drawArc(
        rect,
        start + sweep - tailLen,
        tailLen,
        false,
        Paint()
          ..color = color.withOpacity(0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // 끝점 하이라이트
    final tipAngle = start + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(tip, 3.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OrbitTrailPainter old) {
    return old.turns != turns || old.radius != radius || old.color != color;
  }
}

/// QRS만 또렷한 심전도 (P/T 언덕 없음)
///
/// baseline → Q ↓ → R ↑↑ → S ↓↓ → baseline
class _PqrstEcgPainter extends CustomPainter {
  _PqrstEcgPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final baseY = h * 0.55;

    final path = Path()..moveTo(0, baseY);

    // 앞 baseline
    path.lineTo(w * 0.28, baseY);

    // QRS — 직선으로 또렷하게
    path.lineTo(w * 0.34, baseY + h * 0.12); // Q
    path.lineTo(w * 0.42, baseY - h * 0.48); // R (높게)
    path.lineTo(w * 0.50, baseY + h * 0.32); // S (깊게)
    path.lineTo(w * 0.56, baseY); // baseline 복귀

    // 뒤 baseline
    path.lineTo(w, baseY);

    for (final metric in path.computeMetrics()) {
      final len = metric.length * progress.clamp(0.0, 1.0);
      canvas.drawPath(metric.extractPath(0, len), paint);

      if (progress < 1.0) {
        final tan = metric.getTangentForOffset(len);
        if (tan != null) {
          canvas.drawCircle(tan.position, 3.0, Paint()..color = color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PqrstEcgPainter old) {
    return old.progress != progress || old.color != color;
  }
}