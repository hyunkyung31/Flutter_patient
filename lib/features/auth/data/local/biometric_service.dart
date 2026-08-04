import 'package:flutter/foundation.dart';
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
      if (!supported) return false;
      final canCheck = await _auth.canCheckBiometrics;
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
      final ok = await canCheckBiometrics();
      if (!ok) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // PIN/패턴 폴백 허용
      );
    } catch (e) {
      debugPrint('Biometric authenticate failed: $e');
      return false;
    }
  }
}
