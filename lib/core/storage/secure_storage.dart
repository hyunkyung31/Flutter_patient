import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

class SecureStorageService {
  // Android: EncryptedSharedPreferences 로 기기 재시작 후에도 세션 유지
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

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
    } catch (e) {
      debugPrint('SecureStorage saveToken failed: $e');
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

  /// 로그인 성공 후 한 번에 저장 (자동로그인 기본 ON)
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

    // 저장 검증 (일부 기기에서 write 실패가 조용히 나는 경우 대비)
    final ok = await hasTokens();
    final auto = await isAutoLoginEnabled();
    debugPrint(
      'SecureStorage saveSession ok=$ok autoLogin=$auto '
      'patientId=$patientId',
    );
    if (!ok) {
      throw Exception('로그인 정보 저장에 실패했습니다. 다시 시도해주세요.');
    }
  }

  /// 로그아웃: 토큰/프로필만 삭제. 자동로그인·생체 설정은 기기 선호로 유지.
  static Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: StorageKeys.accessToken),
      _storage.delete(key: StorageKeys.refreshToken),
      _storage.delete(key: StorageKeys.patientId),
      _storage.delete(key: StorageKeys.patientName),
    ]);
  }

  /// 개발/디버그용: 세션 상태 요약
  static Future<String> debugSessionSummary() async {
    final has = await hasTokens();
    final auto = await isAutoLoginEnabled();
    final bio = await isBiometricEnabled();
    final id = await getPatientId();
    return 'hasTokens=$has autoLogin=$auto biometric=$bio patientId=$id';
  }
}
