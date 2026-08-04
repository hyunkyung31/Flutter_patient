import 'package:flutter/material.dart';

import '../controller/health_mission_controller.dart';
import '../widgets/reward_shop_card.dart';

class RewardShopView extends StatelessWidget {
  const RewardShopView({
    super.key,
    required this.controller,
    required this.onBuyPinkFlowerPot,
    required this.onPlantSpecialSeed,
    required this.onToggleButterflyDecoration,
    required this.onBuySpringGardenBackground,
    required this.onToggleSpringGardenBackground,
  });

  final HealthMissionController controller;

  final Future<void> Function() onBuyPinkFlowerPot;
  final Future<void> Function() onPlantSpecialSeed;
  final Future<void> Function() onToggleButterflyDecoration;
  final Future<void> Function() onBuySpringGardenBackground;
  final Future<void> Function() onToggleSpringGardenBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: const Text(
          '보미의 보상 상점',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F5FC),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  _buildPointCard(controller.rewardPoint),
                  const SizedBox(height: 18),

                  RewardShopCard(
                    rewardPoint: controller.rewardPoint,
                    specialSeedCount: controller.specialSeedCount,

                    hasPinkFlowerPot: controller.hasPinkFlowerPot,
                    isSpecialFlowerPlanted: controller.isSpecialFlowerPlanted,
                    isButterflyDecorationEnabled:
                        controller.isButterflyDecorationEnabled,

                    hasSpringGardenBackground:
                        controller.hasSpringGardenBackground,
                    isSpringGardenBackgroundEnabled:
                        controller.isSpringGardenBackgroundEnabled,

                    onBuyFlowerPot: onBuyPinkFlowerPot,
                    onPlantSpecialSeed: onPlantSpecialSeed,

                    onToggleButterflyDecoration: () async {
                      final bool willEnable =
                          !controller.isButterflyDecorationEnabled;

                      await onToggleButterflyDecoration();

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  willEnable
                                      ? Icons.check_circle_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    willEnable
                                        ? '나비 장식이 정원에 적용되었어요.'
                                        : '나비 장식을 정원에서 숨겼어요.',
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                    },

                    onBuySpringGardenBackground: () async {
                      final bool hadBackground =
                          controller.hasSpringGardenBackground;

                      await onBuySpringGardenBackground();

                      if (!context.mounted ||
                          hadBackground ||
                          !controller.hasSpringGardenBackground) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text('봄꽃 정원 배경을 구매하고 바로 적용했어요.'),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                    },

                    onToggleSpringGardenBackground: () async {
                      final bool willEnable =
                          !controller.isSpringGardenBackgroundEnabled;

                      await onToggleSpringGardenBackground();

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  willEnable
                                      ? Icons.landscape_rounded
                                      : Icons.refresh_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    willEnable
                                        ? '봄꽃 정원 배경이 적용되었어요.'
                                        : '기본 정원 배경으로 변경했어요.',
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        );
                    },

                    onGoToGarden: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPointCard(int rewardPoint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8A6BC1), Color(0xFFA888D4)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28755AA7),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.paid_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              '현재 보유 포인트',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$rewardPoint P',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
