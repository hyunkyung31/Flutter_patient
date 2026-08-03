import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // flutter_secure_storage 10+ defaults to AES-GCM custom ciphers on Android.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken({
    required String access,
    required String refresh,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: "access_token", value: access),
        _storage.write(key: "refresh_token", value: refresh),
      ]);
    } catch (_) {
      // Prevent half-written token pairs.
      await _storage.deleteAll();
      rethrow;
    }
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
