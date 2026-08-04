import 'package:flutter/foundation.dart';

class AppDateProvider extends ChangeNotifier {
  DateTime? _testDate;

  /// 테스트 날짜가 설정되어 있으면 테스트 날짜를 반환하고,
  /// 설정되어 있지 않으면 실제 오늘 날짜를 반환합니다.
  DateTime get now {
    return _testDate ?? DateTime.now();
  }

  /// 시간 정보를 제외한 현재 날짜
  DateTime get currentDate {
    final DateTime date = now;

    return DateTime(date.year, date.month, date.day);
  }

  /// 테스트 모드 활성화 여부
  bool get isTestMode {
    return _testDate != null;
  }

  /// 현재 설정된 테스트 날짜
  DateTime? get testDate {
    return _testDate;
  }

  /// 테스트 날짜 직접 설정
  void setTestDate(DateTime date) {
    _testDate = DateTime(date.year, date.month, date.day);

    notifyListeners();
  }

  /// 테스트 날짜를 하루 뒤로 이동
  void moveToNextDay() {
    final DateTime nextDate = currentDate.add(const Duration(days: 1));

    setTestDate(nextDate);
  }

  /// 테스트 날짜를 하루 전으로 이동
  void moveToPreviousDay() {
    final DateTime previousDate = currentDate.subtract(const Duration(days: 1));

    setTestDate(previousDate);
  }

  /// 실제 오늘 날짜로 복귀
  void clearTestDate() {
    _testDate = null;

    notifyListeners();
  }
}
