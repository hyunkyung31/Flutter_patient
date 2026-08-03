import 'package:flutter/material.dart';

import 'reward_shop_view.dart';
import 'mission_list_view.dart';
import '../widgets/health_garden_game.dart';
import '../controller/health_mission_controller.dart';
import '../widgets/flower_stamp_card.dart';
import '../utils/app_date_provider.dart';
import '../widgets/garden_test_panel.dart';
import '../services/step_counter_service.dart';

class HealthMissionView extends StatefulWidget {
  const HealthMissionView({super.key});

  @override
  State<HealthMissionView> createState() => _HealthMissionViewState();
}

class _HealthMissionViewState extends State<HealthMissionView> {
  late final HealthMissionController controller;
  late final AppDateProvider appDateProvider;
  late final StepCounterService stepCounterService;

  bool isHospitalVisitConfirmed = true;

  final int targetSteps = 6000;

  @override
  void initState() {
    super.initState();

    controller = HealthMissionController();
    appDateProvider = AppDateProvider();

    controller.addListener(_refreshView);
    appDateProvider.addListener(_refreshView);

    stepCounterService = StepCounterService();
    stepCounterService.addListener(_refreshView);
    stepCounterService.initialize();

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
    appDateProvider.removeListener(_refreshView);
    stepCounterService.removeListener(_refreshView);

    controller.dispose();
    appDateProvider.dispose();
    stepCounterService.dispose();

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
    bool showGardenButton = false,
    String continueButtonText = '미션 계속하기',
    String gardenButtonText = '정원 확인하기',
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
                if (showGardenButton)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // 팝업만 닫고 미션 페이지에 남습니다.
                            Navigator.of(dialogContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeColor,
                            side: BorderSide(
                              color: themeColor.withValues(alpha: 0.45),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            continueButtonText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            // 완료 팝업을 먼저 닫습니다.
                            Navigator.of(dialogContext).pop();

                            // 다음 프레임에서 미션 페이지를 닫아 정원으로 돌아갑니다.
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) {
                                return;
                              }

                              final NavigatorState navigator = Navigator.of(
                                context,
                              );

                              if (navigator.canPop()) {
                                navigator.pop();
                              }
                            });
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            gardenButtonText,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  )
                else
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
                        '확인',
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

      showGardenButton: true,
    );
  }

  Future<void> _claimWalkingReward() async {
    final bool didComplete = await controller.claimWalkingReward(
      currentSteps: stepCounterService.currentSteps,
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

      showGardenButton: true,
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
          '특별 씨앗 1개와 150P를 받았어요.',
      themeColor: const Color(0xFF8B6FC0),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0E6F8),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.spa_rounded,

      showGardenButton: true,
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

  Future<void> _openMissionView() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return MissionListView(
            controller: controller,
            currentSteps: stepCounterService.currentSteps,
            targetSteps: targetSteps,
            isHospitalVisitConfirmed: isHospitalVisitConfirmed,
            onWaterMissionPressed: _confirmWaterMission,
            onSupplementMissionPressed: _confirmSupplementMission,
            onWalkingMissionPressed: _claimWalkingReward,
            onHospitalMissionPressed: _claimHospitalReward,
          );
        },
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openRewardShop() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return RewardShopView(
            controller: controller,
            onBuyPinkFlowerPot: _buyPinkFlowerPot,
            onPlantSpecialSeed: _plantSpecialSeed,
            onToggleButterflyDecoration: _toggleButterflyDecoration,
            onBuySpringGardenBackground: _buySpringGardenBackground,
            onToggleSpringGardenBackground: _toggleSpringGardenBackground,
          );
        },
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openGardenTestPanel() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: GardenTestPanel(
            controller: controller,
            dateProvider: appDateProvider,
          ),
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleButterflyDecoration() async {
    await controller.toggleButterflyDecoration();
  }

  Future<void> _toggleSpringGardenBackground() async {
    await controller.toggleSpringGardenBackground();
  }

  Future<void> _buySpringGardenBackground() async {
    final bool didBuy = await controller.buySpringGardenBackground();

    if (!didBuy || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('봄꽃 정원 배경을 구매하고 바로 적용했어요.')),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          action: SnackBarAction(
            label: '정원 보기',
            textColor: const Color(0xFFFFD7E4),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
  }

  Future<void> _buyPinkFlowerPot() async {
    final bool didBuy = await controller.buyPinkFlowerPot();

    if (!didBuy || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_smile.png',
      title: '정원 나비 장식을 구매했어요!',
      message:
          '50P를 사용해 나비 장식을 받았어요.\n'
          '구매한 나비가 건강 정원에 바로 적용되었어요.',
      themeColor: const Color(0xFFE46A98),
      backgroundColor: const Color(0xFFFFF7FA),
      circleColor: const Color(0xFFFFEAF1),
      borderColor: const Color(0xFFF4D5E1),
      actionIcon: Icons.auto_awesome_rounded,
      showGardenButton: true,

      // 상점에서 표시할 버튼 문구
      continueButtonText: '상점 계속 보기',
      gardenButtonText: '정원 확인하기',
    );
  }

  Future<void> _plantSpecialSeed() async {
    final bool didReserve = await controller.plantSpecialSeed();

    if (!didReserve || !mounted) {
      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '내일의 특별 꽃을 예약했어요!',
      message:
          '오늘 키운 꽃은 그대로 유지돼요.\n'
          '특별 씨앗은 내일부터 건강 미션과 함께 자라기 시작해요.',
      themeColor: const Color(0xFF7F67B5),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0EAFE),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.nights_stay_rounded,
      showGardenButton: true,
      continueButtonText: '상점 계속 보기',
      gardenButtonText: '정원 확인하기',
    );
  }

  Future<void> _exchangeGifticon() async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),

          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_cafe_rounded,
                size: 30,
                color: Color(0xFF8057B5),
              ),
              SizedBox(height: 12),
              Text(
                '기프티콘으로 교환할까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF344054),
                ),
              ),
            ],
          ),

          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 18),

          content: const Text(
            '꽃 스탬프 10개를 사용해\n'
            '아메리카노 기프티콘으로 교환해요.\n'
            '교환 후 사용한 스탬프는 복구할 수 없어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),

          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8057B5),
              ),
              child: const Text('교환하기'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != true) {
      return;
    }

    final bool didExchange = await controller.exchangeGifticon();

    if (!mounted) {
      return;
    }

    if (!didExchange) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('꽃 스탬프가 부족해요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    _showBomiActionPopup(
      imagePath: 'assets/images/bomi_celebrate.png',
      title: '기프티콘 교환 완료!',
      message:
          '꽃 스탬프 10개를 사용했어요.\n'
          '아메리카노 기프티콘 교환이 완료됐어요.',
      themeColor: const Color(0xFF7F67B5),
      backgroundColor: const Color(0xFFFAF7FD),
      circleColor: const Color(0xFFF0EAFE),
      borderColor: const Color(0xFFE1D3EF),
      actionIcon: Icons.local_cafe_rounded,
    );
  }

  Future<void> _confirmWaterMission() async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE4D7F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2EAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_cafe_rounded,
                    size: 36,
                    color: Color(0xFF8057B5),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  '아메리카노로 교환할까요?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF344054),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  '꽃 스탬프 10개를 사용해\n'
                  '아메리카노 기프티콘으로 교환해요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: Color(0xFF667085),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_florist_rounded,
                        size: 20,
                        color: Color(0xFFE96F9B),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '꽃 스탬프 10개 사용',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE96F9B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8057B5),
                          side: const BorderSide(color: Color(0xFFD8C8E8)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8057B5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '교환하기',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

      showGardenButton: true,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: _openGardenTestPanel,
              tooltip: '정원 테스트 모드',
              icon: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1E9FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.build_circle_rounded,
                  color: Color(0xFF8057B5),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
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
                      isSpringGardenBackgroundEnabled:
                          controller.isSpringGardenBackgroundEnabled,
                      isButterflyDecorationEnabled:
                          controller.isButterflyDecorationEnabled,
                      gardenGrowthPoint: controller.gardenGrowthPoint,
                      specialSeedCount: controller.specialSeedCount,
                      waterDropCount: 0,
                      nutrientCount: controller.nutrientCount,
                      sunlightCount: controller.sunlightCount,

                      hasPinkFlowerPot: controller.hasPinkFlowerPot,
                      isSpecialFlowerPlanted: controller.isSpecialFlowerPlanted,
                      isSpecialSeedReserved: controller.isSpecialSeedReserved,
                      specialFlowerGrowthPoint:
                          controller.specialFlowerGrowthPoint,

                      onWaterPlant: () {},

                      onMissionPressed: _openMissionView,
                      onShopPressed: _openRewardShop,
                    ),

                    const SizedBox(height: 20),

                    FlowerStampCard(
                      stampCount: controller.flowerStampCount,
                      requiredStampCount:
                          HealthMissionController.requiredFlowerStampCount,

                      specialSeedCount: controller.specialSeedCount,
                      gifticonExchangeCount: controller.gifticonExchangeCount,

                      isDailyStampClaimed: controller.isDailyStampClaimed,
                      canClaimDailyStamp: controller.canClaimDailyFlowerStamp,

                      onClaimStampPressed: _claimDailyFlowerStamp,
                      onExchangePressed: _exchangeGifticon,
                    ),

                    const SizedBox(height: 22),
                    // const SizedBox(height: 18),
                    // _buildRewardSection(),
                  ],
                ),
              ),
            ),
    );
  }
}
