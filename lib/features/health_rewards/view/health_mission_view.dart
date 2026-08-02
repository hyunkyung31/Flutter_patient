import 'package:flutter/material.dart';

import '../widgets/health_garden_game.dart';
import '../widgets/health_action_card.dart';
import '../widgets/walking_mission_card.dart';
import '../widgets/hospital_mission_card.dart';
import '../controller/health_mission_controller.dart';
import '../widgets/reward_status_card.dart';
import '../widgets/reward_shop_card.dart';

class HealthMissionView extends StatefulWidget {
  const HealthMissionView({super.key});

  @override
  State<HealthMissionView> createState() => _HealthMissionViewState();
}

class _HealthMissionViewState extends State<HealthMissionView> {
  late final HealthMissionController controller;

  bool isHospitalVisitConfirmed = true;

  int currentSteps = 6200;
  final int targetSteps = 6000;

  @override
  void initState() {
    super.initState();

    controller = HealthMissionController();
    controller.addListener(_refreshView);
    controller.loadMissionState();
  }

  void _refreshView() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refreshView);
    controller.dispose();
    super.dispose();
  }

  void _showBomiActionPopup({
    required String imagePath,
    required String title,
    required String message,
    required Color themeColor,
    required Color backgroundColor,
    required Color circleColor,
    required Color borderColor,
    required IconData actionIcon,
    Alignment iconAlignment = Alignment.bottomRight,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Image.asset(
                      imagePath,
                      width: 175,
                      height: 175,
                      fit: BoxFit.contain,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: iconAlignment,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(actionIcon, size: 40, color: themeColor),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      '정원 확인하기',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSupplementMission() async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.medication_rounded, color: Color(0xFF55A66F)),
              SizedBox(width: 8),
              Text('영양제 챙기기 확인'),
            ],
          ),
          content: const Text(
            '오늘 필요한 영양제를 챙겨 드셨나요?\n완료하면 보미가 정원의 식물에 영양분을 줘요.',
            style: TextStyle(height: 1.5, color: Color(0xFF667085)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('아직이에요'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF55A66F),
              ),
              child: const Text('챙겼어요'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true) {
      return;
    }

    final bool didComplete = await controller.completeSupplementMission();

    if (!didComplete || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_wink.png',
      title: '보미가 영양분을 주었어요!',
      message:
          '영양제를 잘 챙긴 덕분에\n'
          '정원의 식물도 더 건강해졌어요.',
      themeColor: const Color(0xFF55A66F),
      backgroundColor: const Color(0xFFF4FBF6),
      circleColor: const Color(0xFFE3F4E8),
      borderColor: const Color(0xFFD3EBDD),
      actionIcon: Icons.eco_rounded,
    );
  }

  Future<void> _claimWalkingReward() async {
    final bool didComplete = await controller.claimWalkingReward(
      currentSteps: currentSteps,
      targetSteps: targetSteps,
    );

    if (!didComplete || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '목표 걸음 수를 달성했어요!',
      message: '열심히 걸은 덕분에\n보미의 정원에 따뜻한 햇빛이 비쳤어요.',
      themeColor: const Color(0xFFF5A623),
      backgroundColor: const Color(0xFFFFFAEE),
      circleColor: const Color(0xFFFFF1C7),
      borderColor: const Color(0xFFFFE3A3),
      actionIcon: Icons.wb_sunny_rounded,
      iconAlignment: Alignment.topRight,
    );
  }

  Future<void> _claimHospitalReward() async {
    final bool didComplete = await controller.claimHospitalReward(
      isHospitalVisitConfirmed: isHospitalVisitConfirmed,
    );

    if (!didComplete || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '특별 미션 보상을 받았어요!',
      message:
          '병원 진료 완료 보상으로\n'
          '특별 씨앗 1개와 100P를 받았어요.',
      themeColor: const Color(0xFF8B6FC0),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0E6F8),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.spa_rounded,
    );
  }

  Future<void> _claimDailyFlowerStamp() async {
    final bool didClaim = await controller.claimDailyFlowerStamp();

    if (!didClaim || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '꽃 스탬프를 받았어요!',
      message:
          '오늘의 일일 미션을 모두 완료했어요.\n'
          '꽃 스탬프 1개가 보상함에 추가됐어요.',
      themeColor: const Color(0xFFE46A98),
      backgroundColor: const Color(0xFFFFF7FA),
      circleColor: const Color(0xFFFFEAF1),
      borderColor: const Color(0xFFF4D5E1),
      actionIcon: Icons.local_florist_rounded,
    );
  }

  Future<void> _buyPinkFlowerPot() async {
    final bool didBuy = await controller.buyPinkFlowerPot();

    if (!didBuy || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_smile.png',
      title: '분홍 꽃 화분을 구매했어요!',
      message:
          '50P를 사용해 분홍 꽃 화분을 받았어요.\n'
          '이제 보미의 정원을 더 예쁘게 꾸밀 수 있어요.',
      themeColor: const Color(0xFFE46A98),
      backgroundColor: const Color(0xFFFFF7FA),
      circleColor: const Color(0xFFFFEAF1),
      borderColor: const Color(0xFFF4D5E1),
      actionIcon: Icons.yard_rounded,
    );
  }

  Future<void> _plantSpecialSeed() async {
    final bool didPlant = await controller.plantSpecialSeed();

    if (!didPlant || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '특별 씨앗을 심었어요!',
      message:
          '특별 씨앗 1개를 사용했어요.\n'
          '보미의 정원에서 희귀 꽃이 자라기 시작했어요.',
      themeColor: const Color(0xFF7F67B5),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0EAFE),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.local_florist_rounded,
    );
  }

  Future<void> _exchangeGifticon() async {
    final bool didExchange = await controller.exchangeGifticon();

    if (!didExchange || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '기프티콘 교환 완료!',
      message:
          '꽃 스탬프 10개를 사용했어요.\n'
          '기프티콘 교환 신청이 완료됐어요!',
      themeColor: const Color(0xFF7F67B5),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0EAFE),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.card_giftcard_rounded,
    );
  }

  Future<void> _confirmWaterMission() async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.water_drop_rounded, color: Color(0xFF59A7E8)),
              SizedBox(width: 8),
              Text('물 마시기 확인'),
            ],
          ),
          content: const Text(
            '오늘 물을 충분히 마셨나요?\n완료하면 보미가 정원의 꽃에 물을 줘요.',
            style: TextStyle(height: 1.5, color: Color(0xFF667085)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('아직이에요'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF59A7E8),
              ),
              child: const Text('마셨어요'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true) {
      return;
    }

    final bool didComplete = await controller.completeWaterMission();

    if (!didComplete || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_smile.png',
      title: '보미가 꽃에 물을 주었어요!',
      message: '물을 잘 챙겨 마신 덕분에\n정원의 식물도 한 단계 성장했어요.',
      themeColor: const Color(0xFF59A7E8),
      backgroundColor: const Color(0xFFF4FBFF),
      circleColor: const Color(0xFFE3F5FD),
      borderColor: const Color(0xFFCDE8F7),
      actionIcon: Icons.water_drop_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '건강관리 미션',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D2939),
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HealthGardenGame(
                      completedMissionCount:
                          controller.completedDailyMissionCount,
                      totalMissionCount:
                          HealthMissionController.totalDailyMissionCount,
                      gardenGrowthPoint: controller.gardenGrowthPoint,
                      specialSeedCount: controller.specialSeedCount,
                      waterDropCount: 0,
                      nutrientCount: controller.nutrientCount,
                      sunlightCount: controller.sunlightCount,
                      onWaterPlant: () {},
                    ),

                    const SizedBox(height: 22),

                    RewardStatusCard(
                      flowerStampCount: controller.flowerStampCount,
                      requiredFlowerStampCount:
                          HealthMissionController.requiredFlowerStampCount,
                      rewardPoint: controller.rewardPoint,
                      specialSeedCount: controller.specialSeedCount,
                      gifticonExchangeCount: controller.gifticonExchangeCount,
                      areDailyMissionsCompleted:
                          controller.areDailyMissionsCompleted,
                      isDailyStampClaimed: controller.isDailyStampClaimed,
                      onClaimStamp: () {
                        _claimDailyFlowerStamp();
                      },
                      onExchangeGifticon: () {
                        _exchangeGifticon();
                      },
                    ),

                    RewardShopCard(
                      rewardPoint: controller.rewardPoint,
                      specialSeedCount: controller.specialSeedCount,
                      hasPinkFlowerPot: controller.hasPinkFlowerPot,
                      isSpecialFlowerPlanted: controller.isSpecialFlowerPlanted,
                      onBuyFlowerPot: _buyPinkFlowerPot,
                      onPlantSpecialSeed: _plantSpecialSeed,
                    ),

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
                      onPressed: _confirmWaterMission,
                    ),

                    HealthActionCard(
                      title: '영양제 챙기기',
                      description: '오늘 필요한 영양제를 챙겼다면 기록해 주세요.',
                      icon: Icons.medication_rounded,
                      buttonIcon: Icons.medication_rounded,
                      buttonText: '영양제 챙겼어요',
                      isCompleted: controller.isSupplementCompleted,
                      onPressed: _confirmSupplementMission,
                    ),

                    WalkingMissionCard(
                      currentSteps: currentSteps,
                      targetSteps: targetSteps,
                      isCompleted: controller.isWalkingCompleted,
                      onRewardPressed: _claimWalkingReward,
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
                      onRewardPressed: _claimHospitalReward,
                    ),
                    // const SizedBox(height: 18),
                    // _buildRewardSection(),
                  ],
                ),
              ),
            ),
    );
  }
}
