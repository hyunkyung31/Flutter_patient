import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorageService {
  // flutter_secure_storage 10+ defaults to AES-GCM custom ciphers on Android.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ── tokens ──────────────────────────────────────────────
  static Future<void> saveToken({
    required String access,
    required String refresh,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: StorageKeys.accessToken, value: access),
        _storage.write(key: StorageKeys.refreshToken, value: refresh),
      ]);
    } catch (_) {
      // Prevent half-written token pairs.
      await _storage.delete(key: StorageKeys.accessToken);
      await _storage.delete(key: StorageKeys.refreshToken);
      rethrow;
    }
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  static Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return (access != null && access.isNotEmpty) &&
        (refresh != null && refresh.isNotEmpty);
  }

  // ── patient profile (local cache) ───────────────────────
  static Future<void> savePatientProfile({
    String? patientId,
    String? patientName,
  }) async {
    if (patientId != null) {
      await _storage.write(key: StorageKeys.patientId, value: patientId);
    }
    if (patientName != null) {
      await _storage.write(key: StorageKeys.patientName, value: patientName);
    }
  }

  static Future<String?> getPatientId() =>
      _storage.read(key: StorageKeys.patientId);

  static Future<String?> getPatientName() =>
      _storage.read(key: StorageKeys.patientName);

  // ── auto login / biometric flags ────────────────────────
  static Future<void> setAutoLoginEnabled(bool enabled) async {
    await _storage.write(
      key: StorageKeys.autoLoginEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  static Future<bool> isAutoLoginEnabled() async {
    final v = await _storage.read(key: StorageKeys.autoLoginEnabled);
    // 기본값: 토큰이 있으면 자동로그인 시도 (명시적 false만 끔)
    if (v == null) return true;
    return v == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: StorageKeys.biometricEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  static Future<bool> isBiometricEnabled() async {
    final v = await _storage.read(key: StorageKeys.biometricEnabled);
    return v == 'true';
  }

  /// 로그인 성공 후 한 번에 저장
  static Future<void> saveSession({
    required String access,
    required String refresh,
    String? patientId,
    String? patientName,
    bool enableAutoLogin = true,
  }) async {
    await saveToken(access: access, refresh: refresh);
    await savePatientProfile(patientId: patientId, patientName: patientName);
    await setAutoLoginEnabled(enableAutoLogin);
  }

  static Future<void> logout() async {
    // 생체/자동로그인 설정은 기기 선호로 남겨둘 수도 있지만,
    // 로그아웃 시에는 토큰·프로필만 지우고 플래그는 유지해도 됨.
    // 여기서는 안전하게 전부 삭제.
    await _storage.deleteAll();
  }
}
