import 'package:flutter/material.dart';

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
  });

  final int completedMissionCount;
  final int totalMissionCount;
  final int gardenGrowthPoint;

  final int specialSeedCount;
  final int waterDropCount;
  final int nutrientCount;
  final int sunlightCount;

  final VoidCallback onWaterPlant;

  double get growthProgress {
    if (totalMissionCount == 0) {
      return 0;
    }

    return gardenGrowthPoint / totalMissionCount;
  }

  String _getStatusTitle() {
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
    if (completedMissionCount == 0) {
      return '첫 번째 일일 미션을 완료하면 씨앗이 자라기 시작해요.';
    }

    if (completedMissionCount < totalMissionCount) {
      final int remainingMissionCount =
          totalMissionCount - completedMissionCount;

      return '꽃이 피기까지 일일 미션 '
          '$remainingMissionCount개가 남았어요.';
    }

    return '일일 미션을 모두 완료해 오늘의 꽃이 활짝 피었어요!';
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

  String get gardenImagePath {
    switch (gardenGrowthPoint) {
      case 0:
        return 'assets/images/garden/garden_seed.png';
      case 1:
        return 'assets/images/garden/garden_sprout.png';
      case 2:
        return 'assets/images/garden/garden_young_plant.png';
      case 3:
        return 'assets/images/garden/garden_bud.png';
      default:
        return 'assets/images/garden/garden_flower.png';
    }
  }

  IconData get plantIcon {
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

  Widget _buildGameScene() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth >= 700;
        final double sceneHeight = isWideScreen ? 430 : 360;
        final double plantSize = isWideScreen ? 210 : 155;

        return Container(
          height: sceneHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDDF4FF), Color(0xFFF3FBEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // 구름 장식
              const Positioned(
                top: 42,
                left: 32,
                child: Icon(
                  Icons.cloud_rounded,
                  size: 50,
                  color: Color(0xCCFFFFFF),
                ),
              ),
              const Positioned(
                top: 90,
                right: 48,
                child: Icon(
                  Icons.cloud_rounded,
                  size: 38,
                  color: Color(0xB3FFFFFF),
                ),
              ),

              // 오늘 상태 메시지
              Positioned(
                top: 22,
                left: 22,
                right: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: plantColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(plantIcon, color: plantColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1D2939),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _getStatusMessage(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF667085),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 뒤쪽 언덕
              Positioned(
                left: -80,
                right: 180,
                bottom: 52,
                height: 105,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7E09B),
                    borderRadius: BorderRadius.circular(120),
                  ),
                ),
              ),
              Positioned(
                left: 180,
                right: -100,
                bottom: 52,
                height: 125,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFA7D98B),
                    borderRadius: BorderRadius.circular(140),
                  ),
                ),
              ),

              // 앞쪽 잔디
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF8FD06F),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(500, 70),
                    ),
                  ),
                ),
              ),

              // 식물 받침대
              Positioned(
                left: isWideScreen ? 250 : 75,
                right: isWideScreen ? 250 : 75,
                bottom: 28,
                child: Container(
                  height: isWideScreen ? 68 : 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9825D),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),

              // 중앙 성장 식물
              Positioned.fill(
                top: 100,
                bottom: 48,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: CurvedAnimation(
                            parent: animation,
                            curve: Curves.elasticOut,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      plantIcon,
                      key: ValueKey(completedMissionCount),
                      size: plantSize,
                      color: plantColor,
                      shadows: const [
                        Shadow(
                          color: Color(0x26000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 성장 단계 배지
              Positioned(
                left: 22,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    growthStageName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: plantColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameStatus() {
    final double missionProgress = totalMissionCount == 0
        ? 0
        : completedMissionCount / totalMissionCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      color: Colors.white,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$growthStageName · 일일 미션 '
                      '$completedMissionCount개 완료',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: plantColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedMissionCount/$totalMissionCount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: plantColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: missionProgress,
              minHeight: 12,
              backgroundColor: const Color(0xFFE9EEF3),
              valueColor: AlwaysStoppedAnimation<Color>(plantColor),
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
