import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // Kakao
  static String get kakaoNativeAppKey =>
      dotenv.env['KAKAO_NATIVE_APP_KEY']!;

  // Backend
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL']!;

  // 필요하면 앞으로 추가
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
}