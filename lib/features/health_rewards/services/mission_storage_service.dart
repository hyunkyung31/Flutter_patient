import 'package:shared_preferences/shared_preferences.dart';

class MissionStorageData {
  const MissionStorageData({
    required this.isHospitalVisitCompleted,
    required this.isWaterCompleted,
    required this.isSupplementCompleted,
    required this.isWalkingCompleted,
    required this.gardenGrowthPoint,
    required this.specialFlowerGrowthPoint,
    required this.flowerStampCount,
    required this.rewardPoint,
    required this.specialSeedCount,
    required this.isDailyStampClaimed,
    required this.hasPinkFlowerPot,
    required this.isSpecialSeedReserved,
    required this.isSpecialFlowerPlanted,
    required this.gifticonExchangeCount,
    required this.isButterflyDecorationEnabled,
    required this.hasSpringGardenBackground,
    required this.isSpringGardenBackgroundEnabled,
    required this.lastMissionDate,
  });

  final bool isHospitalVisitCompleted;
  final bool isWaterCompleted;
  final bool isSupplementCompleted;
  final bool isWalkingCompleted;

  final int gardenGrowthPoint;
  final int specialFlowerGrowthPoint;

  // 누적 보상
  final int flowerStampCount;
  final int rewardPoint;
  final int specialSeedCount;
  final int gifticonExchangeCount;

  // 오늘 꽃 스탬프를 이미 받았는지 확인
  final bool isDailyStampClaimed;

  // 구매 상품
  final bool hasPinkFlowerPot;

  // 특별 씨앗을 다음 날 심기로 예약한 상태
  final bool isSpecialSeedReserved;

  // 오늘 특별 꽃을 키우고 있는 상태
  final bool isSpecialFlowerPlanted;

  // 나비 표시 상태
  final bool isButterflyDecorationEnabled;

  // 봄꽃 정원 배경 구매 및 적용 상태
  final bool hasSpringGardenBackground;
  final bool isSpringGardenBackgroundEnabled;

  // 마지막으로 미션 상태를 저장한 날짜
  final String lastMissionDate;
}

class MissionStorageService {
  static const String _hospitalCompletedKey = 'isHospitalVisitCompleted';

  static const String _waterCompletedKey = 'isWaterCompleted';

  static const String _supplementCompletedKey = 'isSupplementCompleted';

  static const String _walkingCompletedKey = 'isWalkingCompleted';

  static const String _gardenGrowthPointKey = 'gardenGrowthPoint';

  static const String _specialFlowerGrowthPointKey = 'specialFlowerGrowthPoint';

  static const String _flowerStampCountKey = 'flowerStampCount';

  static const String _rewardPointKey = 'rewardPoint';

  static const String _specialSeedCountKey = 'specialSeedCount';

  static const String _dailyStampClaimedKey = 'isDailyStampClaimed';

  static const String _lastMissionDateKey = 'lastMissionDate';

  static const String _pinkFlowerPotKey = 'hasPinkFlowerPot';

  static const String _specialSeedReservedKey = 'isSpecialSeedReserved';

  static const String _specialFlowerPlantedKey = 'isSpecialFlowerPlanted';

  static const String _gifticonExchangeCountKey = 'gifticonExchangeCount';

  static const String _butterflyDecorationEnabledKey =
      'isButterflyDecorationEnabled';

  static const String _springGardenBackgroundKey = 'hasSpringGardenBackground';

  static const String _springGardenBackgroundEnabledKey =
      'isSpringGardenBackgroundEnabled';

  Future<void> saveMissionState({
    required bool isHospitalVisitCompleted,
    required bool isWaterCompleted,
    required bool isSupplementCompleted,
    required bool isWalkingCompleted,
    required int gardenGrowthPoint,
    required int specialFlowerGrowthPoint,
    required int flowerStampCount,
    required int rewardPoint,
    required int specialSeedCount,
    required int gifticonExchangeCount,
    required bool isDailyStampClaimed,
    required bool hasPinkFlowerPot,
    required bool isSpecialFlowerPlanted,
    required bool isButterflyDecorationEnabled,
    required bool hasSpringGardenBackground,
    required bool isSpringGardenBackgroundEnabled,

    // 기존 컨트롤러가 아직 이 값을 보내지 않아도 오류가 나지 않도록
    // 기본값을 false로 설정합니다.
    bool isSpecialSeedReserved = false,

    // 테스트 날짜가 전달되면 테스트 날짜를 사용하고,
    // 전달되지 않으면 실제 오늘 날짜를 사용합니다.
    DateTime? currentDate,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final DateTime appliedDate = currentDate ?? DateTime.now();

    await preferences.setBool(_hospitalCompletedKey, isHospitalVisitCompleted);

    await preferences.setBool(_waterCompletedKey, isWaterCompleted);

    await preferences.setBool(_supplementCompletedKey, isSupplementCompleted);

    await preferences.setBool(_walkingCompletedKey, isWalkingCompleted);

    await preferences.setInt(_gardenGrowthPointKey, gardenGrowthPoint);

    await preferences.setInt(
      _specialFlowerGrowthPointKey,
      specialFlowerGrowthPoint,
    );

    await preferences.setInt(_flowerStampCountKey, flowerStampCount);

    await preferences.setInt(_rewardPointKey, rewardPoint);

    await preferences.setInt(_specialSeedCountKey, specialSeedCount);

    await preferences.setInt(_gifticonExchangeCountKey, gifticonExchangeCount);

    await preferences.setBool(_dailyStampClaimedKey, isDailyStampClaimed);

    await preferences.setString(_lastMissionDateKey, _formatDate(appliedDate));

    await preferences.setBool(_pinkFlowerPotKey, hasPinkFlowerPot);

    await preferences.setBool(_specialSeedReservedKey, isSpecialSeedReserved);

    await preferences.setBool(_specialFlowerPlantedKey, isSpecialFlowerPlanted);

    await preferences.setBool(
      _butterflyDecorationEnabledKey,
      isButterflyDecorationEnabled,
    );

    await preferences.setBool(
      _springGardenBackgroundKey,
      hasSpringGardenBackground,
    );

    await preferences.setBool(
      _springGardenBackgroundEnabledKey,
      isSpringGardenBackgroundEnabled,
    );
  }

  Future<MissionStorageData> loadMissionState({DateTime? currentDate}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    final DateTime appliedDate = currentDate ?? DateTime.now();

    final String today = _formatDate(appliedDate);

    final String? savedDate = preferences.getString(_lastMissionDateKey);

    final bool isNewDay = savedDate != null && savedDate != today;

    // -------------------------------------------------------------------------
    // 날짜가 바뀌어도 유지되는 누적 데이터
    // -------------------------------------------------------------------------

    final int savedFlowerStampCount =
        preferences.getInt(_flowerStampCountKey) ?? 0;

    final int savedRewardPoint = preferences.getInt(_rewardPointKey) ?? 0;

    final int savedSpecialSeedCount =
        preferences.getInt(_specialSeedCountKey) ?? 0;

    final int savedGifticonExchangeCount =
        preferences.getInt(_gifticonExchangeCountKey) ?? 0;

    final bool savedHospitalCompleted =
        preferences.getBool(_hospitalCompletedKey) ?? false;

    final bool savedHasPinkFlowerPot =
        preferences.getBool(_pinkFlowerPotKey) ?? false;

    final bool savedButterflyEnabled =
        preferences.getBool(_butterflyDecorationEnabledKey) ?? false;

    final bool savedHasSpringGardenBackground =
        preferences.getBool(_springGardenBackgroundKey) ?? false;

    final bool savedSpringBackgroundEnabled =
        preferences.getBool(_springGardenBackgroundEnabledKey) ?? false;

    // -------------------------------------------------------------------------
    // 특별 씨앗 및 특별 꽃 상태
    // -------------------------------------------------------------------------

    final bool savedSpecialSeedReserved =
        preferences.getBool(_specialSeedReservedKey) ?? false;

    final bool savedSpecialFlowerPlanted =
        preferences.getBool(_specialFlowerPlantedKey) ?? false;

    final int savedSpecialFlowerGrowthPoint =
        preferences.getInt(_specialFlowerGrowthPointKey) ?? 0;

    if (isNewDay) {
      final _SpecialFlowerDayState specialFlowerDayState =
          _calculateNextSpecialFlowerState(
            wasReserved: savedSpecialSeedReserved,
            wasPlanted: savedSpecialFlowerPlanted,
          );

      await _resetDailyMissionState(
        preferences: preferences,
        today: today,
        isSpecialSeedReserved: specialFlowerDayState.isSpecialSeedReserved,
        isSpecialFlowerPlanted: specialFlowerDayState.isSpecialFlowerPlanted,
        specialFlowerGrowthPoint:
            specialFlowerDayState.specialFlowerGrowthPoint,
      );

      return MissionStorageData(
        isHospitalVisitCompleted: savedHospitalCompleted,
        isWaterCompleted: false,
        isSupplementCompleted: false,
        isWalkingCompleted: false,
        gardenGrowthPoint: 0,
        specialFlowerGrowthPoint:
            specialFlowerDayState.specialFlowerGrowthPoint,
        flowerStampCount: savedFlowerStampCount,
        rewardPoint: savedRewardPoint,
        specialSeedCount: savedSpecialSeedCount,
        isDailyStampClaimed: false,
        hasPinkFlowerPot: savedHasPinkFlowerPot,
        isSpecialSeedReserved: specialFlowerDayState.isSpecialSeedReserved,
        isSpecialFlowerPlanted: specialFlowerDayState.isSpecialFlowerPlanted,
        gifticonExchangeCount: savedGifticonExchangeCount,
        isButterflyDecorationEnabled: savedButterflyEnabled,
        hasSpringGardenBackground: savedHasSpringGardenBackground,
        isSpringGardenBackgroundEnabled: savedSpringBackgroundEnabled,
        lastMissionDate: today,
      );
    }

    // 최초 실행이라 저장된 날짜가 없다면 오늘 날짜를 기록합니다.
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
      specialFlowerGrowthPoint: savedSpecialFlowerGrowthPoint,
      flowerStampCount: savedFlowerStampCount,
      rewardPoint: savedRewardPoint,
      specialSeedCount: savedSpecialSeedCount,
      isDailyStampClaimed: preferences.getBool(_dailyStampClaimedKey) ?? false,
      hasPinkFlowerPot: savedHasPinkFlowerPot,
      isSpecialSeedReserved: savedSpecialSeedReserved,
      isSpecialFlowerPlanted: savedSpecialFlowerPlanted,
      gifticonExchangeCount: savedGifticonExchangeCount,
      isButterflyDecorationEnabled: savedButterflyEnabled,
      hasSpringGardenBackground: savedHasSpringGardenBackground,
      isSpringGardenBackgroundEnabled: savedSpringBackgroundEnabled,
      lastMissionDate: savedDate ?? today,
    );
  }

  /// 날짜가 변경됐을 때 특별 꽃 상태를 결정합니다.
  ///
  /// 1. 예약된 특별 씨앗이 있으면 오늘 특별 꽃을 시작합니다.
  /// 2. 어제 특별 꽃을 키웠다면 오늘 일반 꽃으로 복귀합니다.
  /// 3. 그 외에는 일반 꽃을 유지합니다.
  _SpecialFlowerDayState _calculateNextSpecialFlowerState({
    required bool wasReserved,
    required bool wasPlanted,
  }) {
    if (wasReserved) {
      return const _SpecialFlowerDayState(
        isSpecialSeedReserved: false,
        isSpecialFlowerPlanted: true,
        specialFlowerGrowthPoint: 0,
      );
    }

    if (wasPlanted) {
      return const _SpecialFlowerDayState(
        isSpecialSeedReserved: false,
        isSpecialFlowerPlanted: false,
        specialFlowerGrowthPoint: 0,
      );
    }

    return const _SpecialFlowerDayState(
      isSpecialSeedReserved: false,
      isSpecialFlowerPlanted: false,
      specialFlowerGrowthPoint: 0,
    );
  }

  Future<void> _resetDailyMissionState({
    required SharedPreferences preferences,
    required String today,
    required bool isSpecialSeedReserved,
    required bool isSpecialFlowerPlanted,
    required int specialFlowerGrowthPoint,
  }) async {
    await preferences.setBool(_waterCompletedKey, false);

    await preferences.setBool(_supplementCompletedKey, false);

    await preferences.setBool(_walkingCompletedKey, false);

    await preferences.setInt(_gardenGrowthPointKey, 0);

    await preferences.setBool(_dailyStampClaimedKey, false);

    await preferences.setBool(_specialSeedReservedKey, isSpecialSeedReserved);

    await preferences.setBool(_specialFlowerPlantedKey, isSpecialFlowerPlanted);

    await preferences.setInt(
      _specialFlowerGrowthPointKey,
      specialFlowerGrowthPoint,
    );

    await preferences.setString(_lastMissionDateKey, today);
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');

    final String day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}

class _SpecialFlowerDayState {
  const _SpecialFlowerDayState({
    required this.isSpecialSeedReserved,
    required this.isSpecialFlowerPlanted,
    required this.specialFlowerGrowthPoint,
  });

  final bool isSpecialSeedReserved;
  final bool isSpecialFlowerPlanted;
  final int specialFlowerGrowthPoint;
}
