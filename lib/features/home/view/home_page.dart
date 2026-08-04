import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

/// 홈 탭 화면 (와이어프레임 맞춤)
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.patientName,
    this.onOpenTab,
  });

  final String? patientName;

  /// 하단탭 이동 콜백
  /// 0홈 1예약 2검사 3길찾기 4마이
  final ValueChanged<int>? onOpenTab;

  @override
  Widget build(BuildContext context) {
    final name = (patientName == null || patientName!.isEmpty)
        ? '환자'
        : patientName!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 로고 + 알림
            Row(
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('알림 센터는 다음 단계에서 연결합니다.')),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 인사 + 보미
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안녕하세요, $name님',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '오늘도 심혈관 건강을\n함께 챙겨볼게요.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const _MascotCluster(),
              ],
            ),
            const SizedBox(height: 18),

            // 다음 예약 | 최근 검사 (한 카드 좌우 분할)
            _SplitStatusCard(
              onReservation: () => onOpenTab?.call(1),
              onExamHistory: () => onOpenTab?.call(2),
            ),
            const SizedBox(height: 20),

            const Text(
              '바로가기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calendar_month_rounded,
                    label: '예약',
                    onTap: () => onOpenTab?.call(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.assignment_rounded,
                    label: '검사',
                    onTap: () => onOpenTab?.call(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.map_rounded,
                    label: '길찾기',
                    onTap: () => onOpenTab?.call(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.person_rounded,
                    label: '내정보',
                    onTap: () => onOpenTab?.call(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 히어로/배너 (이미지 없으면 그라데이션으로 대체 → 검은 박스 방지)
            const _HeroBanner(),
            const SizedBox(height: 12),

            // AI 안내 바
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'AI 상담·진단 결과는 곧 연결될 예정이에요. (수빈 담당 기능)',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MascotCluster extends StatelessWidget {
  const _MascotCluster();

  @override
  Widget build(BuildContext context) {
    Widget one(String path) {
      return Image.asset(
        path,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.favorite_rounded,
          color: AppColors.accent,
          size: 28,
        ),
      );
    }

    return SizedBox(
      width: 100,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 8, child: one('assets/images/mascot/bomi_default.png')),
          Positioned(left: 28, top: 0, child: one('assets/images/mascot/bomi_cheer.png')),
          Positioned(left: 52, top: 18, child: one('assets/images/mascot/bomi_point.png')),
          Positioned(left: 20, top: 46, child: one('assets/images/mascot/bomi_think.png')),
        ],
      ),
    );
  }
}

class _SplitStatusCard extends StatelessWidget {
  const _SplitStatusCard({
    this.onReservation,
    this.onExamHistory,
  });

  final VoidCallback? onReservation;
  final VoidCallback? onExamHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E3A8A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SplitPane(
                title: '다음 예약',
                subtitle: '아직 예정된 예약이 없어요.\n예약을 신청해 보세요.',
                actionLabel: '예약하기',
                onTap: onReservation,
              ),
            ),
            Container(width: 1, color: AppColors.lightBlue),
            Expanded(
              child: _SplitPane(
                title: '최근 검사',
                subtitle: '검사 이력을\n확인해 보세요.',
                actionLabel: '검사이력',
                onTap: onExamHistory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitPane extends StatelessWidget {
  const _SplitPane({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBlue),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 이미지 실패해도 검정 박스 안 나오게 그라데이션 기본
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE0F2FE),
                    Color(0xFFFFE6EA),
                    Color(0xFFDBEAFE),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/images/ui/home_banner.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Image.asset(
                  'assets/images/mascot/bomi_cheer.png',
                  height: 110,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_rounded,
                    size: 72,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 18),
                child: Text(
                  'VENA와 함께\n건강한 하루를!',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
