import 'package:flutter/material.dart';
import 'package:patient_app/core/theme/app_colors.dart';

/// 병원 내부 길찾기 탭 뼈대
class WayfindingPage extends StatelessWidget {
  const WayfindingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '길찾기',
              style: TextStyle(
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
                    Image.asset(
                      'assets/images/mascot/bomi_surprise.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.map_rounded,
                        size: 72,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '병원 내부 길찾기 화면입니다.\n접수/검사실/외래 경로를 다음 단계에서 연결합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
