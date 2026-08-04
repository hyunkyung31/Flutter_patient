import 'package:flutter/material.dart';

class HospitalMissionCard extends StatelessWidget {
  const HospitalMissionCard({
    super.key,
    required this.hospitalName,
    required this.appointmentDate,
    required this.isVisitConfirmed,
    required this.isRewardClaimed,
    required this.onRewardPressed,
  });

  final String hospitalName;
  final String appointmentDate;

  // 실제 프로젝트에서는 서버의 진료 완료 여부로 받게 됩니다.
  final bool isVisitConfirmed;

  final bool isRewardClaimed;
  final VoidCallback? onRewardPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRewardClaimed ? const Color(0xFFF7F2FC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRewardClaimed
              ? const Color(0xFFB79AD8)
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
                  color: const Color(0xFFF1E8FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 28,
                  color: Color(0xFF8B6FC0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '병원 진료 출석',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isRewardClaimed
                          ? '진료 출석 보상을 받았어요!'
                          : isVisitConfirmed
                          ? '진료 완료가 확인되었어요.'
                          : '진료 완료 후 특별 씨앗을 받을 수 있어요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isRewardClaimed
                            ? const Color(0xFF7953A6)
                            : const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildInformationRow(
                  icon: Icons.apartment_rounded,
                  label: '병원',
                  value: hospitalName,
                ),
                const SizedBox(height: 10),
                _buildInformationRow(
                  icon: Icons.calendar_today_rounded,
                  label: '진료 일정',
                  value: appointmentDate,
                ),
                const SizedBox(height: 10),
                _buildInformationRow(
                  icon: isVisitConfirmed
                      ? Icons.verified_rounded
                      : Icons.schedule_rounded,
                  label: '진료 상태',
                  value: isVisitConfirmed ? '진료 완료' : '진료 확인 전',
                  valueColor: isVisitConfirmed
                      ? const Color(0xFF4CA57A)
                      : const Color(0xFF98A2B3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !isVisitConfirmed || isRewardClaimed
                  ? null
                  : onRewardPressed,
              icon: Icon(
                isRewardClaimed
                    ? Icons.check_rounded
                    : isVisitConfirmed
                    ? Icons.spa_rounded
                    : Icons.lock_outline_rounded,
                size: 18,
              ),
              label: Text(
                isRewardClaimed
                    ? '특별 씨앗 받음'
                    : isVisitConfirmed
                    ? '특별 씨앗 받기'
                    : '진료 완료 후 받을 수 있어요',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B6FC0),
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

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF344054),
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: const Color(0xFF8B6FC0)),
        const SizedBox(width: 9),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
