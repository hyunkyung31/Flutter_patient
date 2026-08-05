import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_app/core/theme/app_colors.dart';

import '../../health_rewards/services/step_counter_service.dart';
import '../../reservation/model/reservation.dart';
import '../../reservation/repository/reservation_remote_repository.dart';
import 'package:patient_app/features/ai_consultation/widgets/ai_consultation_preview.dart';

// 시간대별 이미지 선택 함수
String _getWelcomeBomiImage(DateTime now) {
  final int hour = now.hour;

  // 아침: 05:00 ~ 11:59
  if (hour >= 5 && hour < 12) {
    return 'assets/images/bomi_morning.png';
  }

  // 낮·오후: 12:00 ~ 18:59
  if (hour >= 12 && hour < 19) {
    return 'assets/images/bomi_afternoon.png';
  }

  // 저녁·밤·새벽: 19:00 ~ 다음 날 04:59
  return 'assets/images/bomi_evening.png';
}

/// 홈 탭 (시안 피드백 반영)
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.patientName, this.onOpenTab});

  final String? patientName;

  /// 0홈 1예약 2검사 3건강정원 4마이
  final ValueChanged<int>? onOpenTab;

  @override
  Widget build(BuildContext context) {
    final name = (patientName == null || patientName!.isEmpty)
        ? '환자'
        : patientName!;

    return Column(
      children: [
        const _HomeHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              children: [
                _WelcomeCard(name: name),
                const SizedBox(height: 12),
                // 두 카드 높이 동일
                IntrinsicHeight(
                  child: _SummaryCards(
                    onReservation: () => onOpenTab?.call(1),
                    onExamHistory: () => onOpenTab?.call(2),
                  ),
                ),
                const SizedBox(height: 12),
                // 걸음수 카드 (보미 크게 오버랩) → 건강정원
                _StepsCard(onTap: () => onOpenTab?.call(3)),
                const SizedBox(height: 12),
                const AiConsultationPreview(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 10,
        left: 20,
        right: 8,
        bottom: 12,
      ),
      color: AppColors.background,
      child: Row(
        children: [
          Image.asset(
            'assets/images/brand/vena_text.png',
            height: 28,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/vena_text.png',
              height: 28,
              errorBuilder: (_, __, ___) => const Text(
                'vena',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('새로운 건강 알림이 있습니다.')));
            },
            icon: const Badge(
              smallSize: 8,
              backgroundColor: Color(0xFFEF4444),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatefulWidget {
  const _WelcomeCard({required this.name});

  final String name;

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> {
  Timer? _timeTimer;
  late String _bomiImage;

  @override
  void initState() {
    super.initState();

    _bomiImage = _getWelcomeBomiImage(DateTime.now());

    // 시간 변경을 빠르게 감지
    _timeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkTimeImage(),
    );
  }

  void _checkTimeImage() {
    final String nextImage = _getWelcomeBomiImage(DateTime.now());

    // 이미지가 실제로 달라질 때만 화면 갱신
    if (nextImage != _bomiImage && mounted) {
      setState(() {
        _bomiImage = nextImage;
      });
    }
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String bomiImage = _bomiImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1E3A8A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '혈관 건강 케어중',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: '안녕하세요, '),
                      TextSpan(
                        text: '${widget.name}님',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(text: ' 👋'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '오늘도 심혈관 건강을\n함께 꼼꼼하게 챙겨볼게요.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 환영 카드 보미
          SizedBox(
            width: 112,
            height: 112,
            child: ClipRect(
              child: Transform.translate(
                offset: const Offset(-2, 6),
                child: Transform.scale(
                  scale: 1.55,
                  alignment: Alignment.center,
                  child: Image.asset(
                    bomiImage,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite_rounded,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatefulWidget {
  const _SummaryCards({this.onReservation, this.onExamHistory});

  final VoidCallback? onReservation;
  final VoidCallback? onExamHistory;

  @override
  State<_SummaryCards> createState() => _SummaryCardsState();
}

class _SummaryCardsState extends State<_SummaryCards> {
  late Future<Reservation?> _nextReservation;

  @override
  void initState() {
    super.initState();
    _nextReservation = _loadNext();
  }

  Future<Reservation?> _loadNext() async {
    try {
      final list = await ReservationRemoteRepository().fetchAll();
      final now = DateTime.now();
      final upcoming = list.where((e) {
        final active = e.status == ReservationStatus.requested ||
            e.status == ReservationStatus.confirmed;
        return active && e.dateTime.isAfter(now.subtract(const Duration(hours: 1)));
      }).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      if (upcoming.isEmpty) return null;
      return upcoming.first;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder<Reservation?>(
            future: _nextReservation,
            builder: (context, snap) {
              final next = snap.data;
              final subtitle = next == null
                  ? '아직 예정된 예약이 없어요.'
                  : '${DateFormat('M/d HH:mm').format(next.dateTime)}\n'
                      '${next.department} · ${next.doctorName}';
              return _SummaryCard(
                title: '다음 예약',
                icon: Icons.event_available_outlined,
                subtitle: subtitle,
                actionLabel: next == null ? '예약하기' : '예약 보기',
                actionColor: AppColors.lightBlue,
                actionTextColor: AppColors.primary,
                onTap: widget.onReservation,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            title: '최근 검사',
            icon: Icons.medical_information_outlined,
            subtitle: '최근 검사 이력을 바로 확인해보세요.',
            actionLabel: '검사이력',
            actionColor: const Color(0xFFF1F5F9),
            actionTextColor: AppColors.text,
            onTap: widget.onExamHistory,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.actionLabel,
    required this.actionColor,
    required this.actionTextColor,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final String actionLabel;
  final Color actionColor;
  final Color actionTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1E3A8A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: actionTextColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatefulWidget {
  const _StepsCard({this.onTap});

  final VoidCallback? onTap;

  @override
  State<_StepsCard> createState() => _StepsCardState();
}

class _StepsCardState extends State<_StepsCard> {
  static const int _targetSteps = 10000;
  late final StepCounterService _stepService;

  @override
  void initState() {
    super.initState();
    _stepService = StepCounterService();
    _stepService.addListener(_refresh);
    _stepService.initialize();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _stepService.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _stepService.currentSteps;
    final progress = (steps / _targetSteps).clamp(0.0, 1.0);
    final formatter = NumberFormat('#,###');

    // 보미가 카드 밖으로 살짝 튀어나오게
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Ink(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 110, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFEFF6FF),
                      Color(0xFFF0F9FF),
                      Color(0xFFFDF2F8),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E3A8A),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '오늘의 활동',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: formatter.format(steps),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${formatter.format(_targetSteps)} 걸음',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '오늘도 열심히 걸어봐요! 💪',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 큰 보미 오버랩
              Positioned(
                right: -2,
                bottom: -6,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/bomi_walking_cheer.png',
                    width: 126,
                    height: 126,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite_rounded,
                      size: 72,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiNoticeBanner extends StatelessWidget {
  const _AiNoticeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF2F8), Color(0xFFFFF1F2)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFBCFE8)),
      ),
      child: Row(
        children: [
          // 챗봇 아이콘 = 보미 얼굴
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33F59CB3),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/bomi_wink.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/bomi_cheer.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 심혈관 건강 상담 서비스',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '상담 및 진단 결과가 곧 연결될 예정이에요!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBE185D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFF472B6),
            size: 18,
          ),
        ],
      ),
    );
  }
}
