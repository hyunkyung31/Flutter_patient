import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // Kakao
  static String get kakaoNativeAppKey {
    final value = dotenv.env['KAKAO_NATIVE_APP_KEY']?.trim();
    if (value == null || value.isEmpty || value.startsWith('YOUR_')) {
      throw Exception(
        'KAKAO_NATIVE_APP_KEY가 .env에 없습니다.\n'
        '.env.example을 참고해 .env를 설정해주세요.',
      );
    }
    return value;
  }

  // Backend
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null ||
        value.isEmpty ||
        value.contains('your-api.example.com')) {
      throw Exception(
        'API_BASE_URL이 .env에 없습니다.\n'
        '예: API_BASE_URL=http://34.80.83.7:8000\n'
        '설정 후 앱을 다시 실행해주세요.',
      );
    }
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  // 필요하면 앞으로 추가
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
}
