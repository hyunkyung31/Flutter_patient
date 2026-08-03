class LoginResponse {
  final String access;
  final String refresh;
  final String? patientId;
  final String? patientName;
  final bool isNewUser;
  final String? signupToken;

  LoginResponse({
    required this.access,
    required this.refresh,
    this.patientId,
    this.patientName,
    required this.isNewUser,
    this.signupToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access']?.toString() ?? "",
      refresh: json['refresh']?.toString() ?? "",
      patientId: json["patient_id"]?.toString(),
      patientName: json["patient_name"]?.toString(),
      isNewUser: json['is_new_user'] == true,
      signupToken: json['signup_token']?.toString(),
    );
  }
}
