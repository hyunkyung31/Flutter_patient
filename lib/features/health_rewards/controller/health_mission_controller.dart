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

  int specialFlowerGrowthPoint = 0;

  // 오늘 꽃 스탬프 수령 여부
  bool isDailyStampClaimed = false;

  bool hasPinkFlowerPot = false;

  // 구매한 나비 장식을 현재 정원에 표시할지 여부
  bool isButterflyDecorationEnabled = false;

  // 특별 씨앗을 다음 날 심기로 예약했는지 여부
  bool isSpecialSeedReserved = false;

  // 오늘 특별 꽃을 키우고 있는지 여부
  bool isSpecialFlowerPlanted = false;

  // 봄꽃 정원 배경 구매 여부
  bool hasSpringGardenBackground = false;

  // 봄꽃 정원 배경 적용 여부
  bool isSpringGardenBackgroundEnabled = false;

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

  // 예약 여부 확인용
  bool get canReserveSpecialSeed {
    return !isLoading &&
        !isSpecialSeedReserved &&
        !isSpecialFlowerPlanted &&
        specialSeedCount > 0;
  }

  String get specialSeedStatusText {
    if (isSpecialSeedReserved) {
      return '내일 특별 꽃 시작';
    }

    if (isSpecialFlowerPlanted) {
      return '오늘 특별 꽃 성장 중';
    }

    if (specialSeedCount > 0) {
      return '내일의 꽃으로 예약 가능';
    }

    return '보유한 특별 씨앗이 없어요';
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

    try {
      final MissionStorageData savedState = await _missionStorageService
          .loadMissionState();

      _applySavedMissionState(savedState);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeWaterMission() async {
    if (isLoading || isWaterCompleted) {
      return false;
    }

    isWaterCompleted = true;

    _increaseGrowthPoint();
    _increaseSpecialFlowerGrowth();

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
    _increaseSpecialFlowerGrowth();

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
    _increaseSpecialFlowerGrowth();

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

    specialSeedCount++;
    rewardPoint += 150;

    notifyListeners();
    await _saveMissionState();

    return true;
  }

  static const int dailyMissionRewardPoint = 10;

  Future<bool> claimDailyFlowerStamp() async {
    if (isLoading || !canClaimDailyFlowerStamp) {
      return false;
    }

    isDailyStampClaimed = true;
    flowerStampCount++;

    // 일일 미션 완료 포인트 지급
    rewardPoint += dailyMissionRewardPoint;

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
      specialFlowerGrowthPoint: specialFlowerGrowthPoint,

      flowerStampCount: flowerStampCount,
      rewardPoint: rewardPoint,
      specialSeedCount: specialSeedCount,
      gifticonExchangeCount: gifticonExchangeCount,

      isDailyStampClaimed: isDailyStampClaimed,
      hasPinkFlowerPot: hasPinkFlowerPot,
      isSpecialSeedReserved: isSpecialSeedReserved,
      isSpecialFlowerPlanted: isSpecialFlowerPlanted,
      isButterflyDecorationEnabled: isButterflyDecorationEnabled,
      hasSpringGardenBackground: hasSpringGardenBackground,
      isSpringGardenBackgroundEnabled: isSpringGardenBackgroundEnabled,
    );
  }

  static const int pinkFlowerPotPrice = 50;
  static const int springGardenBackgroundPrice = 100;

  Future<bool> buyPinkFlowerPot() async {
    if (isLoading || hasPinkFlowerPot || rewardPoint < pinkFlowerPotPrice) {
      return false;
    }

    rewardPoint -= pinkFlowerPotPrice;

    // 나비 장식 구매 완료
    hasPinkFlowerPot = true;

    // 구매 직후에는 정원에 바로 표시
    isButterflyDecorationEnabled = true;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> toggleButterflyDecoration() async {
    // 구매하지 않은 사용자는 켜고 끌 수 없습니다.
    if (isLoading || !hasPinkFlowerPot) {
      return false;
    }

    isButterflyDecorationEnabled = !isButterflyDecorationEnabled;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> buySpringGardenBackground() async {
    if (isLoading ||
        hasSpringGardenBackground ||
        rewardPoint < springGardenBackgroundPrice) {
      return false;
    }

    rewardPoint -= springGardenBackgroundPrice;

    // 봄꽃 배경 구매 완료
    hasSpringGardenBackground = true;

    // 구매 직후 바로 정원에 적용
    isSpringGardenBackgroundEnabled = true;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> toggleSpringGardenBackground() async {
    if (isLoading || !hasSpringGardenBackground) {
      return false;
    }

    isSpringGardenBackgroundEnabled = !isSpringGardenBackgroundEnabled;

    notifyListeners();

    await _saveMissionState();

    return true;
  }

  Future<bool> plantSpecialSeed() async {
    if (isLoading ||
        isSpecialSeedReserved ||
        isSpecialFlowerPlanted ||
        specialSeedCount < 1) {
      return false;
    }

    // 보유 중인 특별 씨앗 1개 사용
    specialSeedCount--;

    // 오늘 바로 심지 않고 내일의 특별 꽃으로 예약
    isSpecialSeedReserved = true;

    // 오늘 정원은 일반 꽃 상태를 유지
    isSpecialFlowerPlanted = false;
    specialFlowerGrowthPoint = 0;

    notifyListeners();
    await _saveMissionState();

    return true;
  }

  void _increaseSpecialFlowerGrowth() {
    if (!isSpecialFlowerPlanted) {
      return;
    }

    if (specialFlowerGrowthPoint < totalDailyMissionCount) {
      specialFlowerGrowthPoint++;
    }
  }

  void _applySavedMissionState(MissionStorageData savedState) {
    isHospitalVisitCompleted = savedState.isHospitalVisitCompleted;
    isWaterCompleted = savedState.isWaterCompleted;
    isSupplementCompleted = savedState.isSupplementCompleted;
    isWalkingCompleted = savedState.isWalkingCompleted;

    gardenGrowthPoint = savedState.gardenGrowthPoint;
    specialFlowerGrowthPoint = savedState.specialFlowerGrowthPoint;

    flowerStampCount = savedState.flowerStampCount;
    rewardPoint = savedState.rewardPoint;
    specialSeedCount = savedState.specialSeedCount;
    gifticonExchangeCount = savedState.gifticonExchangeCount;

    isDailyStampClaimed = savedState.isDailyStampClaimed;

    hasPinkFlowerPot = savedState.hasPinkFlowerPot;
    isButterflyDecorationEnabled = savedState.isButterflyDecorationEnabled;

    hasSpringGardenBackground = savedState.hasSpringGardenBackground;

    isSpringGardenBackgroundEnabled =
        savedState.isSpringGardenBackgroundEnabled;

    isSpecialSeedReserved = savedState.isSpecialSeedReserved;

    isSpecialFlowerPlanted = savedState.isSpecialFlowerPlanted;
  }

  // ---------------------------------------------------------------------------
  // 테스트·시연 전용 기능
  // ---------------------------------------------------------------------------

  /// 오늘의 일일 미션 상태만 초기화합니다.
  ///
  /// 포인트, 꽃 스탬프, 상점 구매 내역, 특별 씨앗은 유지됩니다.
  Future<void> resetTodayForTest() async {
    if (isLoading) {
      return;
    }

    isHospitalVisitCompleted = false;
    isWaterCompleted = false;
    isSupplementCompleted = false;
    isWalkingCompleted = false;

    gardenGrowthPoint = 0;
    isDailyStampClaimed = false;

    // 오늘 특별 꽃을 키우고 있었다면 성장 단계만 초기화합니다.
    if (isSpecialFlowerPlanted) {
      specialFlowerGrowthPoint = 0;
    }

    notifyListeners();
    await _saveMissionState();
  }

  /// 아직 완료하지 않은 일일 미션을 순서대로 1개 완료합니다.
  ///
  /// 물 마시기 → 영양제 → 걷기 순서로 진행됩니다.
  Future<bool> completeNextDailyMissionForTest() async {
    if (isLoading || areDailyMissionsCompleted) {
      return false;
    }

    if (!isWaterCompleted) {
      isWaterCompleted = true;
    } else if (!isSupplementCompleted) {
      isSupplementCompleted = true;
    } else if (!isWalkingCompleted) {
      isWalkingCompleted = true;
    }

    _increaseGrowthPoint();
    _increaseSpecialFlowerGrowth();

    notifyListeners();
    await _saveMissionState();

    return true;
  }

  /// 오늘의 일일 미션 3개를 한 번에 완료합니다.
  Future<bool> completeAllDailyMissionsForTest() async {
    if (isLoading || areDailyMissionsCompleted) {
      return false;
    }

    isWaterCompleted = true;
    isSupplementCompleted = true;
    isWalkingCompleted = true;

    gardenGrowthPoint = totalDailyMissionCount;

    if (isSpecialFlowerPlanted) {
      specialFlowerGrowthPoint = totalDailyMissionCount;
    }

    notifyListeners();
    await _saveMissionState();

    return true;
  }

  /// 테스트용 특별 씨앗을 1개 지급합니다.
  Future<void> addSpecialSeedForTest() async {
    if (isLoading) {
      return;
    }

    specialSeedCount++;

    notifyListeners();
    await _saveMissionState();
  }

  // 테스트용 스탬프 지급
  Future<void> addFlowerStampForTest() async {
    if (isLoading) {
      return;
    }

    flowerStampCount++;

    notifyListeners();
    await _saveMissionState();
  }

  Future<void> fillFlowerStampsForTest() async {
    if (isLoading) {
      return;
    }

    flowerStampCount = requiredFlowerStampCount;

    notifyListeners();
    await _saveMissionState();
  }

  /// 테스트용 포인트를 지급합니다.
  Future<void> addRewardPointForTest(int point) async {
    if (isLoading || point <= 0) {
      return;
    }

    rewardPoint += point;

    notifyListeners();
    await _saveMissionState();
  }

  /// 병원 미션을 완료 상태로 만들고 실제 보상을 함께 지급합니다.
  Future<bool> completeHospitalMissionForTest() async {
    if (isLoading || isHospitalVisitCompleted) {
      return false;
    }

    isHospitalVisitCompleted = true;
    specialSeedCount++;
    rewardPoint += 150;

    notifyListeners();
    await _saveMissionState();

    return true;
  }

  // 테스트 날짜 적용
  Future<void> applyTestDate(DateTime date) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final MissionStorageData savedState = await _missionStorageService
          .loadMissionState(currentDate: date);

      _applySavedMissionState(savedState);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
