import 'package:flutter/material.dart';

import '../controller/health_mission_controller.dart';
import '../widgets/health_action_card.dart';
import '../widgets/hospital_mission_card.dart';
import '../widgets/walking_mission_card.dart';
import '../services/step_counter_service.dart';

class MissionListView extends StatelessWidget {
  const MissionListView({
    super.key,
    required this.controller,
    required this.stepCounterService,
    required this.targetSteps,
    required this.isHospitalVisitConfirmed,
    required this.onWaterMissionPressed,
    required this.onSupplementMissionPressed,
    required this.onWalkingMissionPressed,
    required this.onHospitalMissionPressed,
  });

  final HealthMissionController controller;

  final StepCounterService stepCounterService;
  final int targetSteps;
  final bool isHospitalVisitConfirmed;

  final Future<void> Function() onWaterMissionPressed;
  final Future<void> Function() onSupplementMissionPressed;
  final Future<void> Function() onWalkingMissionPressed;
  final Future<void> Function() onHospitalMissionPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, stepCounterService]),
      builder: (context, child) {
        final int currentSteps = stepCounterService.currentSteps;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              '건강 미션',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D2939),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMissionSummary(),
                  const SizedBox(height: 26),

                  const Text(
                    '오늘의 일일 미션',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '세 가지 미션을 완료하고 오늘의 꽃을 피워보세요.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 18),

                  HealthActionCard(
                    title: '물 마시기',
                    description: '오늘의 물 마시기 목표를 달성했다면 기록해 주세요.',
                    icon: Icons.water_drop_rounded,
                    buttonIcon: Icons.water_drop_rounded,
                    buttonText: '물 마셨어요',
                    isCompleted: controller.isWaterCompleted,
                    onPressed: onWaterMissionPressed,
                  ),

                  HealthActionCard(
                    title: '영양제 챙기기',
                    description: '오늘 필요한 영양제를 챙겼다면 기록해 주세요.',
                    icon: Icons.medication_rounded,
                    buttonIcon: Icons.medication_rounded,
                    buttonText: '영양제 챙겼어요',
                    isCompleted: controller.isSupplementCompleted,
                    onPressed: onSupplementMissionPressed,
                  ),

                  WalkingMissionCard(
                    currentSteps: currentSteps,
                    targetSteps: targetSteps,
                    isCompleted: controller.isWalkingCompleted,
                    onRewardPressed: onWalkingMissionPressed,
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '특별 미션',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '병원 진료를 완료하면 특별 씨앗과 추가 포인트를 받을 수 있어요.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
                  ),
                  const SizedBox(height: 18),

                  HospitalMissionCard(
                    hospitalName: '보미대학교병원',
                    appointmentDate: '2026년 8월 2일',
                    isVisitConfirmed: isHospitalVisitConfirmed,
                    isRewardClaimed: controller.isHospitalVisitCompleted,
                    onRewardPressed: onHospitalMissionPressed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionSummary() {
    final int completedCount = controller.completedDailyMissionCount;

    final double progress =
        completedCount / HealthMissionController.totalDailyMissionCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4D8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Color(0xFF8057B5)),
              const SizedBox(width: 8),
              const Text(
                '오늘의 미션 진행도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF344054),
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount/'
                '${HealthMissionController.totalDailyMissionCount}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8057B5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8057B5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
