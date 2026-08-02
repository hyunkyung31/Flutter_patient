import 'package:shared_preferences/shared_preferences.dart';

class MissionStorageData {
  const MissionStorageData({
    required this.isHospitalVisitCompleted,
    required this.isWaterCompleted,
    required this.isSupplementCompleted,
    required this.isWalkingCompleted,
    required this.gardenGrowthPoint,
    required this.flowerStampCount,
    required this.rewardPoint,
    required this.specialSeedCount,
    required this.isDailyStampClaimed,
    required this.hasPinkFlowerPot,
    required this.isSpecialFlowerPlanted,
    required this.gifticonExchangeCount,
  });

  final bool isHospitalVisitCompleted;
  final bool isWaterCompleted;
  final bool isSupplementCompleted;
  final bool isWalkingCompleted;

  final int gardenGrowthPoint;

  // 누적 보상
  final int flowerStampCount;
  final int rewardPoint;
  final int specialSeedCount;
  final int gifticonExchangeCount;

  // 오늘 꽃 스탬프를 이미 받았는지 확인
  final bool isDailyStampClaimed;
  final bool hasPinkFlowerPot;
  final bool isSpecialFlowerPlanted;
}

class MissionStorageService {
  static const String _hospitalCompletedKey = 'isHospitalVisitCompleted';
  static const String _waterCompletedKey = 'isWaterCompleted';
  static const String _supplementCompletedKey = 'isSupplementCompleted';
  static const String _walkingCompletedKey = 'isWalkingCompleted';
  static const String _gardenGrowthPointKey = 'gardenGrowthPoint';
  static const String _flowerStampCountKey = 'flowerStampCount';
  static const String _rewardPointKey = 'rewardPoint';
  static const String _specialSeedCountKey = 'specialSeedCount';
  static const String _dailyStampClaimedKey = 'isDailyStampClaimed';
  static const String _lastMissionDateKey = 'lastMissionDate';
  static const String _pinkFlowerPotKey = 'hasPinkFlowerPot';
  static const String _specialFlowerPlantedKey = 'isSpecialFlowerPlanted';
  static const String _gifticonExchangeCountKey = 'gifticonExchangeCount';

  Future<void> saveMissionState({
    required bool isHospitalVisitCompleted,
    required bool isWaterCompleted,
    required bool isSupplementCompleted,
    required bool isWalkingCompleted,
    required int gardenGrowthPoint,
    required int flowerStampCount,
    required int rewardPoint,
    required int specialSeedCount,
    required int gifticonExchangeCount,
    required bool isDailyStampClaimed,
    required bool hasPinkFlowerPot,
    required bool isSpecialFlowerPlanted,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_hospitalCompletedKey, isHospitalVisitCompleted);
    await preferences.setBool(_waterCompletedKey, isWaterCompleted);
    await preferences.setBool(_supplementCompletedKey, isSupplementCompleted);
    await preferences.setBool(_walkingCompletedKey, isWalkingCompleted);
    await preferences.setInt(_gardenGrowthPointKey, gardenGrowthPoint);
    await preferences.setInt(_flowerStampCountKey, flowerStampCount);
    await preferences.setInt(_rewardPointKey, rewardPoint);
    await preferences.setInt(_specialSeedCountKey, specialSeedCount);
    await preferences.setBool(_dailyStampClaimedKey, isDailyStampClaimed);
    await preferences.setString(_lastMissionDateKey, _getTodayDate());
    await preferences.setBool(_pinkFlowerPotKey, hasPinkFlowerPot);
    await preferences.setBool(_specialFlowerPlantedKey, isSpecialFlowerPlanted);
    await preferences.setInt(_gifticonExchangeCountKey, gifticonExchangeCount);
  }

  Future<MissionStorageData> loadMissionState() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final String today = _getTodayDate();

    final String? savedDate = preferences.getString(_lastMissionDateKey);

    final bool isNewDay = savedDate != null && savedDate != today;

    // 누적 보상은 날짜가 바뀌어도 유지합니다.
    final int savedFlowerStampCount =
        preferences.getInt(_flowerStampCountKey) ?? 0;

    final int savedRewardPoint = preferences.getInt(_rewardPointKey) ?? 0;

    final int savedSpecialSeedCount =
        preferences.getInt(_specialSeedCountKey) ?? 0;

    final int savedGifticonExchangeCount =
        preferences.getInt(_gifticonExchangeCountKey) ?? 0;

    // 병원 특별 미션 보상도 현재는 유지합니다.
    final bool savedHospitalCompleted =
        preferences.getBool(_hospitalCompletedKey) ?? false;

    if (isNewDay) {
      await _resetDailyMissionState(preferences: preferences, today: today);

      return MissionStorageData(
        isHospitalVisitCompleted: savedHospitalCompleted,
        isWaterCompleted: false,
        isSupplementCompleted: false,
        isWalkingCompleted: false,
        gardenGrowthPoint: 0,
        flowerStampCount: savedFlowerStampCount,
        rewardPoint: savedRewardPoint,
        specialSeedCount: savedSpecialSeedCount,
        isDailyStampClaimed: false,
        hasPinkFlowerPot: preferences.getBool(_pinkFlowerPotKey) ?? false,
        isSpecialFlowerPlanted:
            preferences.getBool(_specialFlowerPlantedKey) ?? false,
        gifticonExchangeCount: savedGifticonExchangeCount,
      );
    }

    if (savedDate == null) {
      await preferences.setString(_lastMissionDateKey, today);
    }

    return MissionStorageData(
      isHospitalVisitCompleted: savedHospitalCompleted,
      isWaterCompleted: preferences.getBool(_waterCompletedKey) ?? false,
      isSupplementCompleted:
          preferences.getBool(_supplementCompletedKey) ?? false,
      isWalkingCompleted: preferences.getBool(_walkingCompletedKey) ?? false,
      gardenGrowthPoint: preferences.getInt(_gardenGrowthPointKey) ?? 0,
      flowerStampCount: savedFlowerStampCount,
      rewardPoint: savedRewardPoint,
      specialSeedCount: savedSpecialSeedCount,
      isDailyStampClaimed: preferences.getBool(_dailyStampClaimedKey) ?? false,
      hasPinkFlowerPot: preferences.getBool(_pinkFlowerPotKey) ?? false,
      isSpecialFlowerPlanted:
          preferences.getBool(_specialFlowerPlantedKey) ?? false,
      gifticonExchangeCount: savedGifticonExchangeCount,
    );
  }

  Future<void> _resetDailyMissionState({
    required SharedPreferences preferences,
    required String today,
  }) async {
    await preferences.setBool(_waterCompletedKey, false);

    await preferences.setBool(_supplementCompletedKey, false);

    await preferences.setBool(_walkingCompletedKey, false);

    await preferences.setInt(_gardenGrowthPointKey, 0);

    // 날짜가 바뀌면 오늘의 스탬프 수령 여부만 초기화합니다.
    await preferences.setBool(_dailyStampClaimedKey, false);

    await preferences.setString(_lastMissionDateKey, today);
  }

  String _getTodayDate() {
    final DateTime now = DateTime.now();

    final String month = now.month.toString().padLeft(2, '0');

    final String day = now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }
}
