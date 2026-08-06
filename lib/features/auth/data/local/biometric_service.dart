import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// 기기 잠금 가능 여부 상세
class BiometricCapability {
  const BiometricCapability({
    required this.deviceSupported,
    required this.canCheckBiometrics,
    required this.availableTypes,
  });

  /// PIN/패턴/생체 중 하나라도 기기 잠금이 가능한지
  final bool deviceSupported;

  /// 지문/Face 하드웨어·등록 여부 체크 가능
  final bool canCheckBiometrics;

  final List<BiometricType> availableTypes;

  /// 설정 토글을 켤 수 있는지 (PIN만 있어도 true)
  bool get canUseAppLock => deviceSupported;

  bool get hasEnrolledBiometrics => availableTypes.isNotEmpty;

  String get summaryLabel {
    if (!deviceSupported) {
      return '이 기기는 아직 잠금(지문/PIN)이 없습니다.';
    }
    if (hasEnrolledBiometrics) {
      return '지문/Face로 앱 잠금을 사용할 수 있습니다. (PIN 폴백 가능)';
    }
    return '화면 잠금(PIN/패턴)으로 앱 잠금을 사용할 수 있습니다.';
  }
}

/// 지문 / Face ID / 기기 잠금(PIN·패턴) 래퍼
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricCapability> getCapability() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      debugPrint(
        'Biometric capability: supported=$supported '
        'canCheck=$canCheck types=$types',
      );
      return BiometricCapability(
        deviceSupported: supported,
        canCheckBiometrics: canCheck,
        availableTypes: types,
      );
    } catch (e) {
      debugPrint('Biometric getCapability failed: $e');
      return const BiometricCapability(
        deviceSupported: false,
        canCheckBiometrics: false,
        availableTypes: [],
      );
    }
  }

  /// 기기에서 앱 잠금(생체 또는 PIN)을 쓸 수 있는지
  Future<bool> canCheckBiometrics() async {
    final cap = await getCapability();
    return cap.canUseAppLock;
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// true = 인증 성공
  Future<bool> authenticate({
    String reason = '앱 잠금을 해제하려면 인증해주세요.',
  }) async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        debugPrint('Biometric authenticate: device not supported');
        return false;
      }

      // biometricOnly:false → 지문 없으면 PIN/패턴으로 인증
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
      debugPrint('Biometric authenticate result=$ok');
      return ok;
    } on PlatformException catch (e) {
      debugPrint(
        'Biometric authenticate PlatformException: '
        'code=${e.code} message=${e.message}',
      );
      return false;
    } catch (e) {
      debugPrint('Biometric authenticate failed: $e');
      return false;
    }
  }
}
