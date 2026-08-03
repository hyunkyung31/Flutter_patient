import '../model/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> loginWithKakao();

  Future<LoginResponse> signupWithKakao({
    required String signupToken,
    required String phone,
    required String birthDate,
    String? name,
  });

  Future<LoginResponse> refreshToken();

  Future<void> logout();
}