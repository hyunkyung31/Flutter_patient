import 'package:flutter/material.dart';

class WalkingMissionCard extends StatelessWidget {
  const WalkingMissionCard({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
    required this.isCompleted,
    required this.onRewardPressed,
  });

  final int currentSteps;
  final int targetSteps;
  final bool isCompleted;
  final VoidCallback? onRewardPressed;

  bool get isGoalReached {
    return currentSteps >= targetSteps;
  }

  double get progress {
    if (targetSteps <= 0) {
      return 0;
    }

    final double value = currentSteps / targetSteps;

    if (value > 1) {
      return 1;
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (progress * 100).round();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFFFF8E7) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFFFC95C)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  size: 28,
                  color: Color(0xFFF5A623),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '걸음 수 달성',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isCompleted
                          ? '오늘의 걸음 수 미션을 완료했어요!'
                          : '목표 걸음 수를 달성하면 햇빛 보상을 받을 수 있어요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCompleted
                            ? const Color(0xFFB77900)
                            : const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '${_formatNumber(currentSteps)}보',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1D2939),
                ),
              ),
              const Spacer(),
              Text(
                '목표 ${_formatNumber(targetSteps)}보',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667085),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F2F4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF5A623),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$progressPercent% 달성',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB77900),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isCompleted || !isGoalReached ? null : onRewardPressed,
              icon: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : isGoalReached
                    ? Icons.wb_sunny_rounded
                    : Icons.lock_outline_rounded,
                size: 18,
              ),
              label: Text(
                isCompleted
                    ? '보상 받음'
                    : isGoalReached
                    ? '햇빛 보상 받기'
                    : '목표 달성 후 보상 받기',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF5A623),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1F2F4),
                disabledForegroundColor: const Color(0xFF98A2B3),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    final String number = value.toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      final int positionFromEnd = number.length - i;

      result.write(number[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        result.write(',');
      }
    }

    return result.toString();
  }
}
