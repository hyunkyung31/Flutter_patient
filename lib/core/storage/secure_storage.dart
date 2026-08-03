import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static Future<void> saveToken({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(
      key: "access_token",
      value: access,
    );

    await _storage.write(
      key: "refresh_token",
      value: refresh,
    );
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}