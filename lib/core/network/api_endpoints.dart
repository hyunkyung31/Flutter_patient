class ApiEndpoints {
  // Must match Django: path("api/auth/kakao/login/", ...)
  // trailing slash 필수 (없으면 Django 404)
  static const String kakaoLogin = '/api/auth/kakao/login/';
  static const String kakaoSignup = '/api/auth/kakao/signup/';
  static const String refresh = '/api/token/refresh/';
}
