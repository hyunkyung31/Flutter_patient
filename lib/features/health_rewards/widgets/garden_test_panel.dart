import 'package:flutter/material.dart';

import '../controller/health_mission_controller.dart';
import '../utils/app_date_provider.dart';

class GardenTestPanel extends StatefulWidget {
  const GardenTestPanel({
    super.key,
    required this.controller,
    required this.dateProvider,
  });

  final HealthMissionController controller;
  final AppDateProvider dateProvider;

  @override
  State<GardenTestPanel> createState() => _GardenTestPanelState();
}

class _GardenTestPanelState extends State<GardenTestPanel> {
  bool _isProcessing = false;

  HealthMissionController get controller {
    return widget.controller;
  }

  AppDateProvider get dateProvider {
    return widget.dateProvider;
  }

  String get _formattedDate {
    final DateTime date = dateProvider.currentDate;

    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Future<void> _runTestAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(successMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _selectTestDate() async {
    if (_isProcessing) {
      return;
    }

    final DateTime currentDate = dateProvider.currentDate;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      helpText: '테스트 날짜 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    if (_isSameDate(currentDate, selectedDate)) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      dateProvider.setTestDate(selectedDate);

      await controller.applyTestDate(dateProvider.currentDate);

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '${selectedDate.year}년 '
              '${selectedDate.month}월 '
              '${selectedDate.day}일로 이동했어요.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _moveToPreviousDay() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      dateProvider.moveToPreviousDay();

      await controller.applyTestDate(dateProvider.currentDate);

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('테스트 날짜가 $_formattedDate로 변경됐어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _moveToNextDay() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      dateProvider.moveToNextDay();

      await controller.applyTestDate(dateProvider.currentDate);

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('테스트 날짜가 $_formattedDate로 변경됐어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _returnToToday() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      dateProvider.clearTestDate();

      await controller.applyTestDate(dateProvider.currentDate);

      if (!mounted) {
        return;
      }

      setState(() {});

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('실제 오늘 날짜로 돌아왔어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _completeNextMission() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bool didComplete = await controller
          .completeNextDailyMissionForTest();

      if (!mounted) {
        return;
      }

      if (!didComplete) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('이미 일일 미션을 모두 완료했어요.'),
              behavior: SnackBarBehavior.floating,
            ),
          );

        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '일일 미션을 1개 완료했어요. '
              '(${controller.completedDailyMissionCount}/'
              '${HealthMissionController.totalDailyMissionCount})',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _completeAllMissions() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bool didComplete = await controller
          .completeAllDailyMissionsForTest();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              didComplete ? '오늘의 일일 미션을 모두 완료했어요.' : '이미 일일 미션을 모두 완료했어요.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _completeHospitalMission() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bool didComplete = await controller
          .completeHospitalMissionForTest();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              didComplete
                  ? '병원 미션 완료! 특별 씨앗 1개와 150P를 지급했어요.'
                  : '병원 미션은 이미 완료된 상태예요.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _reserveSpecialSeed() async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final bool didReserve = await controller.plantSpecialSeed();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              didReserve ? '특별 씨앗을 내일의 꽃으로 예약했어요.' : '특별 씨앗을 예약할 수 없는 상태예요.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DDF6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFECDDFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF8057B5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateProvider.isTestMode ? '테스트 날짜' : '실제 오늘 날짜',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8057B5),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2540),
                      ),
                    ),
                  ],
                ),
              ),
              if (dateProvider.isTestMode)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8057B5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'TEST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TestActionButton(
                  icon: Icons.chevron_left_rounded,
                  label: '하루 전',
                  onPressed: _isProcessing ? null : _moveToPreviousDay,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TestActionButton(
                  icon: Icons.calendar_today_rounded,
                  label: '날짜 선택',
                  onPressed: _isProcessing ? null : _selectTestDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TestActionButton(
                  icon: Icons.chevron_right_rounded,
                  label: '하루 뒤',
                  onPressed: _isProcessing ? null : _moveToNextDay,
                ),
              ),
            ],
          ),
          if (dateProvider.isTestMode) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _returnToToday,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('실제 오늘 날짜로 돌아가기'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _StatusChip(
            icon: Icons.task_alt_rounded,
            label:
                '일일 미션 '
                '${controller.completedDailyMissionCount}/'
                '${HealthMissionController.totalDailyMissionCount}',
          ),
          _StatusChip(
            icon: Icons.local_florist_rounded,
            label: '성장 ${controller.gardenGrowthPoint}',
          ),
          _StatusChip(
            icon: Icons.auto_awesome_rounded,
            label: '특별 씨앗 ${controller.specialSeedCount}개',
          ),
          _StatusChip(
            icon: controller.isSpecialSeedReserved
                ? Icons.schedule_rounded
                : controller.isSpecialFlowerPlanted
                ? Icons.local_florist_rounded
                : Icons.event_available_rounded,
            label: controller.specialSeedStatusText,
          ),
          _StatusChip(
            icon: Icons.stars_rounded,
            label: '${controller.rewardPoint}P',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: Listenable.merge([controller, dateProvider]),
        builder: (context, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.build_circle_rounded, color: Color(0xFF8057B5)),
                    SizedBox(width: 8),
                    Text(
                      '정원 테스트 모드',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '앱 데이터를 삭제하지 않고 날짜와 보상 상태를 '
                  '빠르게 변경할 수 있어요.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 20),

                _buildStatusCard(),
                const SizedBox(height: 14),
                _buildMissionStatus(),
                const SizedBox(height: 22),

                const _SectionTitle(
                  icon: Icons.task_alt_rounded,
                  title: '일일 미션 테스트',
                ),
                const SizedBox(height: 10),

                _TestMenuTile(
                  icon: Icons.restart_alt_rounded,
                  title: '오늘 미션 초기화',
                  subtitle: '포인트와 구매 상품은 유지하고 오늘 진행도만 초기화해요.',
                  onTap: _isProcessing
                      ? null
                      : () {
                          _runTestAction(
                            controller.resetTodayForTest,
                            successMessage: '오늘 미션 상태를 초기화했어요.',
                          );
                        },
                ),
                _TestMenuTile(
                  icon: Icons.looks_one_rounded,
                  title: '일일 미션 1개 완료',
                  subtitle: '물 → 영양제 → 걷기 순서로 하나씩 완료해요.',
                  onTap: _isProcessing ? null : _completeNextMission,
                ),
                _TestMenuTile(
                  icon: Icons.done_all_rounded,
                  title: '일일 미션 모두 완료',
                  subtitle: '꽃 완성과 스탬프 수령 화면을 빠르게 확인해요.',
                  onTap: _isProcessing ? null : _completeAllMissions,
                ),

                const SizedBox(height: 22),
                const _SectionTitle(
                  icon: Icons.card_giftcard_rounded,
                  title: '보상 테스트',
                ),
                const SizedBox(height: 10),

                _TestMenuTile(
                  icon: Icons.local_hospital_rounded,
                  title: '병원 미션 완료',
                  subtitle: '특별 씨앗 1개와 150P를 함께 지급해요.',
                  onTap: _isProcessing ? null : _completeHospitalMission,
                ),
                _TestMenuTile(
                  icon: Icons.auto_awesome_rounded,
                  title: '특별 씨앗 1개 지급',
                  subtitle: '병원 미션과 관계없이 테스트용 씨앗을 추가해요.',
                  onTap: _isProcessing
                      ? null
                      : () {
                          _runTestAction(
                            controller.addSpecialSeedForTest,
                            successMessage: '특별 씨앗 1개를 지급했어요.',
                          );
                        },
                ),
                _TestMenuTile(
                  icon: Icons.event_available_rounded,
                  title: '특별 씨앗 내일 심기 예약',
                  subtitle: controller.isSpecialSeedReserved
                      ? '이미 내일의 특별 꽃으로 예약된 상태예요.'
                      : controller.isSpecialFlowerPlanted
                      ? '오늘은 이미 특별 꽃을 키우고 있어요.'
                      : '특별 씨앗 1개를 사용해 내일의 꽃으로 예약해요.',
                  onTap: _isProcessing || !controller.canReserveSpecialSeed
                      ? null
                      : _reserveSpecialSeed,
                ),
                _TestMenuTile(
                  icon: Icons.stars_rounded,
                  title: '포인트 150P 지급',
                  subtitle: '나비와 봄꽃 정원 배경 구매를 바로 테스트해요.',
                  onTap: _isProcessing
                      ? null
                      : () {
                          _runTestAction(
                            () => controller.addRewardPointForTest(150),
                            successMessage: '테스트 포인트 150P를 지급했어요.',
                          );
                        },
                ),
                _TestMenuTile(
                  icon: Icons.local_florist_rounded,
                  title: '꽃 스탬프 1개 지급',
                  subtitle: '스탬프가 한 칸씩 채워지는 상태를 확인해요.',
                  onTap: _isProcessing
                      ? null
                      : () {
                          _runTestAction(
                            controller.addFlowerStampForTest,
                            successMessage: '꽃 스탬프 1개를 지급했어요.',
                          );
                        },
                ),

                _TestMenuTile(
                  icon: Icons.auto_awesome_rounded,
                  title: '꽃 스탬프 10개 채우기',
                  subtitle: '기프티콘 교환 가능 상태를 바로 확인해요.',
                  onTap: _isProcessing
                      ? null
                      : () {
                          _runTestAction(
                            controller.fillFlowerStampsForTest,
                            successMessage: '꽃 스탬프를 10개로 채웠어요.',
                          );
                        },
                ),

                if (_isProcessing) ...[
                  const SizedBox(height: 18),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8057B5)),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF344054),
          ),
        ),
      ],
    );
  }
}

class _TestMenuTile extends StatelessWidget {
  const _TestMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1E9FA),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF8057B5)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF344054),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TestActionButton extends StatelessWidget {
  const _TestActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8057B5)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF475467),
            ),
          ),
        ],
      ),
    );
  }
}
