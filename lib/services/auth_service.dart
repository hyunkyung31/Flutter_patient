import '../core/storage/secure_storage.dart';

/// 세션/토큰 조회용 헬퍼. 실제 카카오·병원 로그인은 auth feature 쪽을 사용한다.
class AuthService {
  Future<String?> getPatientId() => SecureStorageService.getPatientId();

  Future<String?> getAccessToken() => SecureStorageService.getAccessToken();

  Future<void> logout() => SecureStorageService.logout();
}
