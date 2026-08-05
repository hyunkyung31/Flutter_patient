import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// 지문 / Face ID / 기기 잠금 생체인증 래퍼
class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// 기기에서 생체인증(또는 기기 자격증명)을 쓸 수 있는지
  Future<bool> canCheckBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        debugPrint('Biometric: device not supported');
        return false;
      }
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      debugPrint(
        'Biometric: canCheck=$canCheck supported=$supported types=$types',
      );
      // 생체 미등록이어도 기기 PIN/패턴이 있으면 isDeviceSupported=true
      return canCheck || supported;
    } catch (e) {
      debugPrint('Biometric canCheck failed: $e');
      return false;
    }
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

      // local_auth ^3.0.2: biometricOnly 는 top-level
      // false = 지문/Face 실패 시 기기 PIN·패턴 폴백 허용
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
