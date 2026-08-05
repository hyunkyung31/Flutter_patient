import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterService extends ChangeNotifier {
  static const String _savedStepsKey = 'health_today_steps';
  static const String _lastSensorStepsKey = 'health_last_sensor_steps';
  static const String _savedDateKey = 'health_steps_saved_date';

  StreamSubscription<StepCount>? _stepCountSubscription;

  int _currentSteps = 0;
  int? _lastSensorSteps;

  bool _isInitialized = false;
  bool _isPermissionGranted = false;
  bool _isSensorAvailable = false;

  String? _errorMessage;

  int get currentSteps => _currentSteps;

  bool get isInitialized => _isInitialized;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isSensorAvailable => _isSensorAvailable;

  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    _errorMessage = null;

    await _loadSavedSteps();
    notifyListeners();

    final PermissionStatus permissionStatus =
        await Permission.activityRecognition.request();

    _isPermissionGranted = permissionStatus.isGranted;

    if (!_isPermissionGranted) {
      _errorMessage = permissionStatus.isPermanentlyDenied
          ? '활동 인식 권한이 차단되어 있어요. 앱 설정에서 권한을 허용해 주세요.'
          : '걸음 수 측정을 위해 활동 인식 권한이 필요해요.';

      notifyListeners();
      return;
    }

    _startPedometerStream();
  }

  Future<void> _loadSavedSteps() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String today = _formatDate(DateTime.now());
    final String? savedDate = preferences.getString(_savedDateKey);

    if (savedDate == today) {
      _currentSteps = preferences.getInt(_savedStepsKey) ?? 0;
      _lastSensorSteps = preferences.getInt(_lastSensorStepsKey);

      debugPrint(
        '저장된 걸음 수 복원: $_currentSteps '
        '(이전 센서값: $_lastSensorSteps)',
      );
    } else {
      _currentSteps = 0;
      _lastSensorSteps = null;

      await preferences.setInt(_savedStepsKey, 0);
      await preferences.remove(_lastSensorStepsKey);
      await preferences.setString(_savedDateKey, today);

      debugPrint('날짜 변경으로 걸음 수를 초기화했습니다.');
    }
  }

  void _startPedometerStream() {
    _stepCountSubscription?.cancel();

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );
    } catch (error) {
      _isSensorAvailable = false;
      _errorMessage = '이 기기에서는 걸음 수 센서를 사용할 수 없어요.';

      debugPrint('Pedometer 초기화 오류: $error');
      notifyListeners();
    }
  }

  Future<void> _onStepCount(StepCount event) async {
    _isSensorAvailable = true;
    _errorMessage = null;

    final int sensorSteps = event.steps;
    final String today = _formatDate(DateTime.now());

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? savedDate = preferences.getString(_savedDateKey);

    if (savedDate != today) {
      _currentSteps = 0;
      _lastSensorSteps = sensorSteps;

      await _saveSteps(
        sensorSteps: sensorSteps,
        date: today,
      );

      debugPrint('새 날짜의 센서 기준값 설정: $sensorSteps');
      notifyListeners();
      return;
    }

    if (_lastSensorSteps == null) {
      _lastSensorSteps = sensorSteps;

      await _saveSteps(
        sensorSteps: sensorSteps,
        date: today,
      );

      debugPrint(
        '첫 센서 기준값 설정: $sensorSteps '
        '(복원된 걸음 수: $_currentSteps)',
      );

      notifyListeners();
      return;
    }

    if (sensorSteps >= _lastSensorSteps!) {
      final int increasedSteps = sensorSteps - _lastSensorSteps!;

      _currentSteps += increasedSteps;
    } else {
      // 휴대전화 재부팅 등으로 센서 누적값이 초기화된 경우입니다.
      debugPrint(
        '센서 누적값 초기화 감지 '
        '(이전: $_lastSensorSteps / 현재: $sensorSteps)',
      );
    }

    _lastSensorSteps = sensorSteps;

    await _saveSteps(
      sensorSteps: sensorSteps,
      date: today,
    );

    debugPrint(
      '걸음 수 업데이트: $_currentSteps '
      '(센서 전체: $sensorSteps)',
    );

    notifyListeners();
  }

  Future<void> _saveSteps({
    required int sensorSteps,
    required String date,
  }) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setInt(_savedStepsKey, _currentSteps);
    await preferences.setInt(_lastSensorStepsKey, sensorSteps);
    await preferences.setString(_savedDateKey, date);
  }

  String _formatDate(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void _onStepCountError(Object error) {
    _isSensorAvailable = false;
    _errorMessage = '걸음 수 센서 정보를 가져오지 못했어요.';

    debugPrint('Pedometer 스트림 오류: $error');
    notifyListeners();
  }

  /// 에뮬레이터와 발표 테스트용입니다.
  Future<void> setTestSteps(int steps) async {
    _currentSteps = steps < 0 ? 0 : steps;

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setInt(_savedStepsKey, _currentSteps);
    await preferences.setString(
      _savedDateKey,
      _formatDate(DateTime.now()),
    );

    notifyListeners();
  }

  /// 오늘 걸음 수 저장값을 초기화합니다.
  Future<void> resetTodaySteps() async {
    _currentSteps = 0;
    _lastSensorSteps = null;

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setInt(_savedStepsKey, 0);
    await preferences.remove(_lastSensorStepsKey);
    await preferences.setString(
      _savedDateKey,
      _formatDate(DateTime.now()),
    );

    notifyListeners();
  }

  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }
}