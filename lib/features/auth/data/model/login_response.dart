class LoginResponse {
  final String access;
  final String refresh;
  final String? patientId;
  final String? patientName;
  final bool isNewUser;

  LoginResponse({
    required this.access,
    required this.refresh,
    this.patientId,
    this.patientName,
    required this.isNewUser,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'] ?? "",
      refresh: json['refresh'] ?? "",
      patientId: json["patient_id"],
      patientName: json["patient_name"],
      isNewUser: json['is_new_user'] ?? false,
    );
  }
}
