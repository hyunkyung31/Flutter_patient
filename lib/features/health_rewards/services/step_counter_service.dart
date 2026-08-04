import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterService extends ChangeNotifier {
  StreamSubscription<StepCount>? _stepCountSubscription;

  int _currentSteps = 0;
  int? _sensorStartSteps;

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

    notifyListeners();

    final PermissionStatus permissionStatus = await Permission
        .activityRecognition
        .request();

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

  void _onStepCount(StepCount event) {
    _isSensorAvailable = true;
    _errorMessage = null;

    final int sensorSteps = event.steps;

    // 첫 센서 값을 앱 실행 시점의 기준값으로 사용합니다.
    _sensorStartSteps ??= sensorSteps;

    // 휴대전화 재부팅 등으로 센서 누적값이 작아진 경우 기준점을 다시 잡습니다.
    if (sensorSteps < _sensorStartSteps!) {
      _sensorStartSteps = sensorSteps;
    }

    final int calculatedSteps = sensorSteps - _sensorStartSteps!;

    _currentSteps = calculatedSteps < 0 ? 0 : calculatedSteps;

    debugPrint(
      '걸음 수 업데이트: $_currentSteps '
      '(센서 전체: $sensorSteps / 시작값: $_sensorStartSteps)',
    );

    notifyListeners();
  }

  void _onStepCountError(Object error) {
    _isSensorAvailable = false;
    _errorMessage = '걸음 수 센서 정보를 가져오지 못했어요.';

    debugPrint('Pedometer 스트림 오류: $error');
    notifyListeners();
  }

  /// 에뮬레이터와 발표 테스트용입니다.
  void setTestSteps(int steps) {
    _currentSteps = steps < 0 ? 0 : steps;
    notifyListeners();
  }

  /// 실제 센서 기준값을 다시 설정합니다.
  void resetSessionSteps() {
    _sensorStartSteps = null;
    _currentSteps = 0;
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
