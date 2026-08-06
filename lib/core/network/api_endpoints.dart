class ApiEndpoints {
  // Must match Django: path("api/auth/kakao/login/", ...)
  // trailing slash 필수 (없으면 Django 404)
  static const String kakaoLogin = '/api/auth/kakao/login/';
  static const String kakaoSignup = '/api/auth/kakao/signup/';
  static const String refresh = '/api/token/refresh/';
  static const String me = '/api/me/';

  static const String doctors = '/api/doctors/';

  /// 환자 상세(+ examinations, ai_results)
  static String patientDetail(String patientId) =>
      '/api/patients/$patientId/';

  /// 진료 예약 (Django Appointment)
  static const String appointments = '/api/appointments/';
  static const String appointmentsMe = '/api/appointments/me/';
  static String appointmentDetail(String id) => '/api/appointments/$id/';
}
