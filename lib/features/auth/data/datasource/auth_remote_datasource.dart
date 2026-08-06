import '../model/login_response.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> loginWithKakao();

  Future<LoginResponse> signupWithKakao({
    required String signupToken,
    required String phone,
    required String birthDate,
    required String name,
  });

  /// 아이디(또는 휴대폰) + 비밀번호 로그인
  Future<LoginResponse> loginWithPassword({
    required String username,
    required String password,
  });

  /// 병원 등록 환자 인증 후 아이디/비밀번호 회원가입
  Future<LoginResponse> signupWithPassword({
    required String name,
    required String phone,
    required String birthDate,
    required String password,
    String? username,
  });

  Future<LoginResponse> refreshToken();

  Future<void> logout();
}
