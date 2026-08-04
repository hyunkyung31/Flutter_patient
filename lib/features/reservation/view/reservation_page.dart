import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

/// 예약 탭 뼈대 (신청·조회·변경)
class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturePlaceholder(
      title: '예약',
      description: '진료 예약 신청·조회·변경 화면입니다.\n다음 단계에서 기능을 연결합니다.',
      icon: Icons.calendar_month_rounded,
      mascotAsset: 'assets/images/mascot/bomi_point.png',
    );
  }
}

class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder({
    required this.title,
    required this.description,
    required this.icon,
    this.mascotAsset,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? mascotAsset;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mascotAsset != null)
                      Image.asset(
                        mascotAsset!,
                        width: 120,
                        height: 120,
                        errorBuilder: (_, __, ___) => Icon(
                          icon,
                          size: 72,
                          color: AppColors.accent,
                        ),
                      )
                    else
                      Icon(icon, size: 72, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
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
