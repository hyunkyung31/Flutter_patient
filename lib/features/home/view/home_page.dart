import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

/// 홈 탭 화면
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/brand/vena_text.png',
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
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                Image.asset(
                  'assets/images/mascot/bomi_cheer.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/mascot/bomi_default.png',
                    width: 92,
                    height: 92,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite_rounded,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoCard(
              title: '다음 예약',
              subtitle: '아직 예정된 예약이 없어요.\n예약을 신청해 보세요.',
              actionLabel: '예약하기',
              onTap: () => onOpenTab?.call(1),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: '최근 검사',
              subtitle: '검사 이력을 확인해 보세요.',
              actionLabel: '검사이력',
              onTap: () => onOpenTab?.call(2),
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6EA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mascot/bomi_point.png',
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.smart_toy_outlined,
                      color: AppColors.accent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI 상담·진단 결과는 곧 연결될 예정이에요.\n(수빈 담당 기능)',
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
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
