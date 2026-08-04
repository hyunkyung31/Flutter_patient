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

  /// 신규 가입이 필요한지
  bool get needsSignup =>
      isNewUser || (signupToken != null && signupToken!.isNotEmpty);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final signupToken = _readString(json, const [
      'signup_token',
      'signupToken',
    ]);

    final isNewUser = _readBool(json, const [
          'is_new_user',
          'isNewUser',
        ]) ||
        (signupToken != null && signupToken.isNotEmpty);

    return LoginResponse(
      access: _readString(json, const ['access', 'access_token']) ?? '',
      refresh: _readString(json, const ['refresh', 'refresh_token']) ?? '',
      patientId: _readString(json, const ['patient_id', 'patientId']),
      patientName: _readString(json, const ['patient_name', 'patientName']),
      isNewUser: isNewUser,
      signupToken: signupToken,
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') continue;
      return text;
    }
    return null;
  }

  static bool _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == true || value == 1) return true;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
      }
    }
    return false;
  }
}