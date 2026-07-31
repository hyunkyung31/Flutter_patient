import '../model/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> loginWithKakao();

  Future<LoginResponse> refreshToken();

  Future<void> logout();
}