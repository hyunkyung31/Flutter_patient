import 'package:flutter/material.dart';

import 'fluttering_butterfly.dart';

class HealthGardenGame extends StatelessWidget {
  const HealthGardenGame({
    super.key,
    required this.completedMissionCount,
    required this.totalMissionCount,
    required this.gardenGrowthPoint,
    required this.specialSeedCount,
    required this.waterDropCount,
    required this.nutrientCount,
    required this.sunlightCount,
    required this.onWaterPlant,
    required this.hasPinkFlowerPot,
    required this.isSpecialFlowerPlanted,
    required this.specialFlowerGrowthPoint,
    required this.onMissionPressed,
    required this.onShopPressed,
    required this.isButterflyDecorationEnabled,
    required this.isSpringGardenBackgroundEnabled,
    required this.isSpecialSeedReserved,
  });

  final int completedMissionCount;
  final int totalMissionCount;
  final int gardenGrowthPoint;

  final int specialSeedCount;
  final int specialFlowerGrowthPoint;
  final int waterDropCount;
  final int nutrientCount;
  final int sunlightCount;

  final bool hasPinkFlowerPot;
  final bool isSpecialFlowerPlanted;
  final bool isButterflyDecorationEnabled;
  final bool isSpringGardenBackgroundEnabled;
  final bool isSpecialSeedReserved;

  final VoidCallback onWaterPlant;
  final VoidCallback onMissionPressed;
  final VoidCallback onShopPressed;

  double get growthProgress {
    if (totalMissionCount == 0) {
      return 0;
    }

    final int currentGrowthPoint = isSpecialFlowerPlanted
        ? specialFlowerGrowthPoint
        : completedMissionCount;

    return (currentGrowthPoint / totalMissionCount).clamp(0.0, 1.0);
  }

  String _getStatusTitle() {
    if (isSpecialFlowerPlanted) {
      switch (specialFlowerGrowthPoint) {
        case 0:
          return '특별 씨앗이 정원에 심어졌어요!';
        case 1:
          return '희귀 꽃 새싹이 돋아났어요!';
        case 2:
          return '희귀 꽃이 피기 직전이에요!';
        default:
          return '희귀 꽃이 완성됐어요!';
      }
    }

    switch (completedMissionCount) {
      case 0:
        return '오늘의 건강 미션을 시작해 볼까요?';
      case 1:
        return '정원에 새싹이 돋아났어요!';
      case 2:
        return '꽃이 피기 직전이에요!';
      default:
        return '오늘의 건강 꽃이 완성됐어요!';
    }
  }

  String _getStatusMessage() {
    if (isSpecialFlowerPlanted) {
      if (specialFlowerGrowthPoint == 0) {
        return '어제 예약한 특별 씨앗이 오늘의 꽃이 되었어요. '
            '건강 미션을 완료해 희귀 꽃을 키워보세요.';
      }

      if (specialFlowerGrowthPoint < totalMissionCount) {
        final int remainingMissionCount =
            totalMissionCount - specialFlowerGrowthPoint;

        return '희귀 꽃이 완성되기까지 일일 미션 '
            '$remainingMissionCount개가 남았어요.';
      }

      return '오늘의 미션을 완료해 희귀 꽃이 활짝 피었어요!';
    }

    if (completedMissionCount == 0) {
      return '첫 번째 일일 미션을 완료하면 씨앗이 자라기 시작해요.';
    }

    if (completedMissionCount < totalMissionCount) {
      final int remainingMissionCount =
          totalMissionCount - completedMissionCount;

      return '꽃이 피기까지 일일 미션 '
          '$remainingMissionCount개가 남았어요.';
    }

    return '오늘의 미션을 모두 완료해 꽃이 활짝 피었어요!';
  }

  String get bomiImagePath {
    if (completedMissionCount == 0) {
      return 'assets/images/bomi_cheer.png';
    }

    if (completedMissionCount <= 2) {
      return 'assets/images/bomi_smile.png';
    }

    if (completedMissionCount == 3) {
      return 'assets/images/bomi_wink.png';
    }

    return 'assets/images/bomi_celebrate.png';
  }

  String get growthStageName {
    switch (completedMissionCount) {
      case 0:
        return '씨앗';
      case 1:
        return '새싹';
      case 2:
        return '꽃봉오리';
      default:
        return '꽃 완성';
    }
  }

  String get displayedPlantName {
    if (!isSpecialFlowerPlanted) {
      return growthStageName;
    }

    switch (specialFlowerGrowthPoint) {
      case 0:
        return '희귀 꽃 씨앗';
      case 1:
        return '희귀 꽃 새싹';
      case 2:
        return '희귀 꽃봉오리';
      default:
        return '희귀 꽃 완성';
    }
  }

  String get plantImagePath {
    // 특별 씨앗을 심은 상태라면 스페셜 꽃 이미지를 표시합니다.
    if (isSpecialFlowerPlanted) {
      switch (specialFlowerGrowthPoint) {
        case 0:
          return 'assets/images/special_flower_stage_0_seed.png';
        case 1:
          return 'assets/images/special_flower_stage_1_sprout.png';
        case 2:
          return 'assets/images/special_flower_stage_2_bud.png';
        default:
          return 'assets/images/special_flower_stage_3_bloom.png';
      }
    }

    // 특별 씨앗을 심지 않았다면 기존 일반 꽃 이미지를 표시합니다.
    switch (completedMissionCount) {
      case 0:
        return 'assets/images/flower_stage_0_seed.png';
      case 1:
        return 'assets/images/flower_stage_1_sprout.png';
      case 2:
        return 'assets/images/flower_stage_2_bud.png';
      default:
        return 'assets/images/flower_stage_3_bloom.png';
    }
  }

  IconData get plantIcon {
    if (isSpecialFlowerPlanted) {
      switch (specialFlowerGrowthPoint) {
        case 0:
          return Icons.circle_rounded;
        case 1:
          return Icons.grass_rounded;
        case 2:
          return Icons.local_florist_rounded;
        default:
          return Icons.filter_vintage_rounded;
      }
    }

    switch (completedMissionCount) {
      case 0:
        return Icons.circle_rounded;
      case 1:
        return Icons.grass_rounded;
      case 2:
        return Icons.local_florist_rounded;
      default:
        return Icons.filter_vintage_rounded;
    }
  }

  Color get plantColor {
    if (isSpecialFlowerPlanted) {
      switch (specialFlowerGrowthPoint) {
        case 0:
          return const Color(0xFFB07A98);
        case 1:
          return const Color(0xFF79A87A);
        case 2:
          return const Color(0xFFD17C9B);
        default:
          return const Color(0xFFE46A98);
      }
    }

    switch (completedMissionCount) {
      case 0:
        return const Color(0xFF9B7653);
      case 1:
        return const Color(0xFF78B96C);
      case 2:
        return const Color(0xFFE990AD);
      default:
        return const Color(0xFFF16F9D);
    }
  }

  String get gameMessage {
    if (isSpecialFlowerPlanted) {
      if (specialFlowerGrowthPoint == 0) {
        return '건강 미션을 완료하고 특별 씨앗을 성장시켜 보세요!';
      }

      if (specialFlowerGrowthPoint < totalMissionCount) {
        return '건강 미션을 완료할 때마다 희귀 꽃이 한 단계씩 자라요.';
      }

      return '축하해요! 특별 씨앗에서 희귀 꽃이 활짝 피었어요.';
    }

    if (completedMissionCount == 0) {
      return '첫 번째 건강 미션을 완료하고 정원을 깨워보세요!';
    }

    if (completedMissionCount < totalMissionCount) {
      return '건강 미션을 완료할 때마다 꽃이 한 단계씩 자라요.';
    }

    return '축하해요! 오늘의 건강 꽃이 활짝 피었어요.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A344054),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: [_buildGameScene(), _buildGameStatus()]),
    );
  }

  Widget _buildGardenMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xE6FFFDF8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x99FFFFFF)),
                ),
                child: Icon(icon, size: 23, color: const Color(0xFF8057B5)),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF344054),
              shadows: [Shadow(color: Colors.white, blurRadius: 5)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScene() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth >= 700;
        final double sceneHeight = isWideScreen ? 430 : 360;

        return Container(
          height: sceneHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isSpringGardenBackgroundEnabled
                    ? 'assets/images/garden_background_spring.png'
                    : 'assets/images/garden_background.png',
              ),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: Stack(
            children: [
              // 오늘 상태 메시지
              Positioned(
                top: 22,
                left: 20,
                right: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF253238),
                        shadows: [
                          Shadow(color: Color(0xB3FFFFFF), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getStatusMessage(),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF526168),
                        shadows: [Shadow(color: Colors.white, blurRadius: 7)],
                      ),
                    ),
                  ],
                ),
              ),

              // 중앙 성장 식물
              Positioned.fill(
                top: isWideScreen ? 132 : 138,
                bottom: isWideScreen ? 10 : 16,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      plantImagePath,
                      key: ValueKey(
                        '$completedMissionCount-'
                        '$specialFlowerGrowthPoint-'
                        '$isSpecialFlowerPlanted-'
                        '$plantImagePath',
                      ),
                      width: isWideScreen
                          ? constraints.maxWidth * 0.58
                          : constraints.maxWidth * 0.75,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                    ),
                  ),
                ),
              ),

              // 구매한 나비 장식
              if (hasPinkFlowerPot && isButterflyDecorationEnabled) ...[
                Positioned(
                  left: 50,
                  top: 131,
                  child: FlutteringButterfly(
                    imagePath: 'assets/images/butterfly_left.png',
                    width: isWideScreen ? 120 : 82,
                  ),
                ),
                Positioned(
                  right: 78,
                  top: 110,
                  child: FlutteringButterfly(
                    imagePath: 'assets/images/butterfly_right.png',
                    width: isWideScreen ? 110 : 72,
                    reverseDirection: true,
                  ),
                ),
              ],

              // 미션 및 상점 버튼
              Positioned(
                top: 72,
                right: 12,
                child: Column(
                  children: [
                    _buildGardenMenuButton(
                      icon: Icons.task_alt_rounded,
                      label: '미션',
                      onTap: onMissionPressed,
                    ),
                    const SizedBox(height: 9),
                    _buildGardenMenuButton(
                      icon: Icons.storefront_rounded,
                      label: '상점',
                      onTap: onShopPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      color: Colors.white.withValues(alpha: 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '보미의 건강 정원',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: plantColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '현재 단계 · $displayedPlantName',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: plantColor,
                            ),
                          ),
                        ),
                        Text(
                          isSpecialFlowerPlanted
                              ? '성장 '
                                    '$specialFlowerGrowthPoint/'
                                    '$totalMissionCount'
                              : '미션 '
                                    '$completedMissionCount/'
                                    '$totalMissionCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: growthProgress >= 1
                      ? const Color(0xFFFFEAF1)
                      : const Color(0xFFF3F5F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  growthProgress >= 1
                      ? isSpecialFlowerPlanted
                            ? '희귀 꽃 완성'
                            : '오늘 미션 완료'
                      : isSpecialFlowerPlanted
                      ? '희귀 꽃 성장 중'
                      : '꽃이 자라는 중',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: growthProgress >= 1
                        ? const Color(0xFFE56894)
                        : const Color(0xFF667085),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: growthProgress,
              minHeight: 14,
              backgroundColor: const Color(0xFFE8EDE4),
              valueColor: AlwaysStoppedAnimation<Color>(
                isSpecialFlowerPlanted
                    ? const Color(0xFFE46A98)
                    : const Color(0xFFE985A8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gameMessage,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
