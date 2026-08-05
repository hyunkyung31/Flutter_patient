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

  /// 환자 AI 챗봇 (Django: path("chat/", ...))
  static const String chat = '/chat/';

  /// AI 상담 세션/히스토리
  static const String chatbotSessions = '/api/chatbot/sessions/';
  static String chatbotSessionDetail(int sessionId) =>
      '/api/chatbot/sessions/$sessionId/';
}
