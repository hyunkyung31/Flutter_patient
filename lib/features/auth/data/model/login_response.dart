class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isNewUser: json['isNewUser'],
    );
  }
}