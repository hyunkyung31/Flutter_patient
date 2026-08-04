import 'package:flutter/material.dart';

class HealthActionCard extends StatelessWidget {
  const HealthActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonIcon,
    required this.buttonText,
    required this.isCompleted,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final IconData buttonIcon;
  final String buttonText;
  final bool isCompleted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFF0F9F4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF4CAF7D)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFDDF3E7)
                  : const Color(0xFFEAF5FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isCompleted
                  ? const Color(0xFF2E8B62)
                  : const Color(0xFF59A7E8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isCompleted ? '오늘의 미션을 완료했어요!' : description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted
                        ? const Color(0xFF2E8B62)
                        : const Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isCompleted ? null : onPressed,
                    icon: Icon(
                      isCompleted ? Icons.check_rounded : buttonIcon,
                      size: 18,
                    ),
                    label: Text(isCompleted ? '완료됨' : buttonText),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF59A7E8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFDDF3E7),
                      disabledForegroundColor: const Color(0xFF2E8B62),
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
          ),
        ],
      ),
    );
  }
}
