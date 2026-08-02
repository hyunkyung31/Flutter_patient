import 'package:flutter/foundation.dart';

import '../services/mission_storage_service.dart';

class HealthMissionController extends ChangeNotifier {
  HealthMissionController({MissionStorageService? missionStorageService})
    : _missionStorageService = missionStorageService ?? MissionStorageService();

  final MissionStorageService _missionStorageService;

  bool isHospitalVisitCompleted = false;
  bool isWaterCompleted = false;
  bool isSupplementCompleted = false;
  bool isWalkingCompleted = false;

  int gardenGrowthPoint = 0;

  // 누적 보상
  int flowerStampCount = 0;
  int rewardPoint = 0;
  int specialSeedCount = 0;
  int gifticonExchangeCount = 0;

  // 오늘 꽃 스탬프 수령 여부
  bool isDailyStampClaimed = false;

  bool hasPinkFlowerPot = false;
  bool isSpecialFlowerPlanted = false;

  bool isLoading = false;

  int get completedDailyMissionCount {
    int count = 0;

    if (isWaterCompleted) count++;
    if (isSupplementCompleted) count++;
    if (isWalkingCompleted) count++;

    return count;
  }

  static const int totalDailyMissionCount = 3;

  bool get areDailyMissionsCompleted {
    return completedDailyMissionCount == totalDailyMissionCount;
  }

  bool get canClaimDailyFlowerStamp {
    return areDailyMissionsCompleted && !isDailyStampClaimed;
  }

  static const int requiredFlowerStampCount = 10;

  bool get canExchangeGifticon {
    return flowerStampCount >= requiredFlowerStampCount;
  }

  int get remainingFlowerStampCount {
    final int remaining = requiredFlowerStampCount - flowerStampCount;

    return remaining < 0 ? 0 : remaining;
  }

  int get nutrientCount {
    return isSupplementCompleted ? 1 : 0;
  }

  int get sunlightCount {
    return isWalkingCompleted ? 1 : 0;
  }

  Future<bool> exchangeGifticon() async {
    if (isLoading || !canExchangeGifticon) {
      return false;
    }

    flowerStampCount -= requiredFlowerStampCount;

    gifticonExchangeCount++;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<void> loadMissionState() async {
    isLoading = true;
    notifyListeners();

    final MissionStorageData savedState = await _missionStorageService
        .loadMissionState();

    isHospitalVisitCompleted = savedState.isHospitalVisitCompleted;
    isWaterCompleted = savedState.isWaterCompleted;
    isSupplementCompleted = savedState.isSupplementCompleted;
    isWalkingCompleted = savedState.isWalkingCompleted;
    gardenGrowthPoint = savedState.gardenGrowthPoint;

    flowerStampCount = savedState.flowerStampCount;
    rewardPoint = savedState.rewardPoint;
    specialSeedCount = savedState.specialSeedCount;
    gifticonExchangeCount = savedState.gifticonExchangeCount;

    isDailyStampClaimed = savedState.isDailyStampClaimed;
    hasPinkFlowerPot = savedState.hasPinkFlowerPot;
    isSpecialFlowerPlanted = savedState.isSpecialFlowerPlanted;

    isLoading = false;
    notifyListeners();
  }

  Future<bool> completeWaterMission() async {
    if (isLoading || isWaterCompleted) {
      return false;
    }

    isWaterCompleted = true;
    _increaseGrowthPoint();

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> completeSupplementMission() async {
    if (isLoading || isSupplementCompleted) {
      return false;
    }

    isSupplementCompleted = true;
    _increaseGrowthPoint();

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> claimWalkingReward({
    required int currentSteps,
    required int targetSteps,
  }) async {
    if (isLoading || isWalkingCompleted || currentSteps < targetSteps) {
      return false;
    }

    isWalkingCompleted = true;
    _increaseGrowthPoint();

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> claimHospitalReward({
    required bool isHospitalVisitConfirmed,
  }) async {
    if (isLoading || !isHospitalVisitConfirmed || isHospitalVisitCompleted) {
      return false;
    }

    isHospitalVisitCompleted = true;

    // 병원 특별 미션 보상
    specialSeedCount++;
    rewardPoint += 100;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> claimDailyFlowerStamp() async {
    if (isLoading || !canClaimDailyFlowerStamp) {
      return false;
    }

    isDailyStampClaimed = true;
    flowerStampCount++;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  void _increaseGrowthPoint() {
    gardenGrowthPoint++;

    if (gardenGrowthPoint > totalDailyMissionCount) {
      gardenGrowthPoint = totalDailyMissionCount;
    }
  }

  Future<void> _saveMissionState() async {
    await _missionStorageService.saveMissionState(
      isHospitalVisitCompleted: isHospitalVisitCompleted,
      isWaterCompleted: isWaterCompleted,
      isSupplementCompleted: isSupplementCompleted,
      isWalkingCompleted: isWalkingCompleted,
      gardenGrowthPoint: gardenGrowthPoint,

      flowerStampCount: flowerStampCount,
      rewardPoint: rewardPoint,
      specialSeedCount: specialSeedCount,
      gifticonExchangeCount: gifticonExchangeCount,

      isDailyStampClaimed: isDailyStampClaimed,
      hasPinkFlowerPot: hasPinkFlowerPot,
      isSpecialFlowerPlanted: isSpecialFlowerPlanted,
    );
  }

  static const int pinkFlowerPotPrice = 50;

  Future<bool> buyPinkFlowerPot() async {
    if (isLoading || hasPinkFlowerPot || rewardPoint < pinkFlowerPotPrice) {
      return false;
    }

    rewardPoint -= pinkFlowerPotPrice;
    hasPinkFlowerPot = true;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> plantSpecialSeed() async {
    if (isLoading || isSpecialFlowerPlanted || specialSeedCount < 1) {
      return false;
    }

    specialSeedCount--;
    isSpecialFlowerPlanted = true;

    notifyListeners();

    await _saveMissionState();

    return true;
  }
}
