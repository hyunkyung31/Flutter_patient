import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_remote_datasource.dart';
import '../model/login_response.dart';

class KakaoAuthService implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> loginWithKakao() async {
    final token = await _loginWithKakaoSdk();
    debugPrint('Kakao SDK login success');

    final requestUrl = '${AppConfig.apiBaseUrl}${ApiEndpoints.kakaoLogin}';
    debugPrint('Backend login request: POST $requestUrl');

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoLogin,
        data: {
          'accessToken': token.accessToken,
        },
      );

      return _parseLoginResponse(response.data);
    } on DioException catch (e) {
      debugPrint(
        'Kakao backend login failed: type=${e.type}, '
        'status=${e.response?.statusCode}, url=$requestUrl, '
        'data=${e.response?.data}',
      );

      // 일부 백엔드는 신규 유저를 404/400 + signup_token 으로 내려줌
      final recovered = _tryParseNewUserFromError(e);
      if (recovered != null) {
        debugPrint('Recovered new-user login response from error body');
        return recovered;
      }

      throw Exception(_mapDioError(e, requestUrl, actionLabel: '로그인'));
    }
  }

  Future<OAuthToken> _loginWithKakaoSdk() async {
    final installed = await isKakaoTalkInstalled();
    debugPrint('KakaoTalk installed: $installed');

    if (!installed) {
      try {
        return await UserApi.instance.loginWithKakaoAccount();
      } catch (e) {
        debugPrint('Kakao account login failed: $e');
        throw Exception('카카오 계정 로그인 실패: $e');
      }
    }

    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (e) {
      // User cancelled Talk login — do not fallback.
      if (e.code == 'CANCELED') rethrow;

      debugPrint('KakaoTalk login failed, falling back to account login: $e');
      try {
        return await UserApi.instance.loginWithKakaoAccount();
      } catch (accountError) {
        debugPrint('Kakao account login failed: $accountError');
        throw Exception('카카오 로그인 실패: $accountError');
      }
    } catch (e) {
      debugPrint('KakaoTalk login failed: $e');
      throw Exception('카카오톡 로그인 실패: $e');
    }
  }

  LoginResponse _parseLoginResponse(dynamic data) {
    if (data is! Map) {
      throw Exception(
        '서버 응답 형식이 올바르지 않습니다. (${data.runtimeType})',
      );
    }
    return LoginResponse.fromJson(Map<String, dynamic>.from(data));
  }

  LoginResponse? _tryParseNewUserFromError(DioException e) {
    final status = e.response?.statusCode;
    if (status == null || status < 400 || status >= 500) return null;

    final data = e.response?.data;
    if (data is! Map) return null;

    final parsed = LoginResponse.fromJson(Map<String, dynamic>.from(data));
    if (parsed.needsSignup) return parsed;
    return null;
  }

  String _mapDioError(
    DioException e,
    String requestUrl, {
    String actionLabel = '로그인',
  }) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return '서버 연결 실패\n$requestUrl\nAPI_BASE_URL을 확인해주세요.';
      case DioExceptionType.badResponse:
        final message = _extractServerMessage(e.response?.data);
        if (message != null) {
          return '서버 $actionLabel 실패 (${e.response?.statusCode})\n$message';
        }
        return '서버 $actionLabel 실패 (${e.response?.statusCode})\n$requestUrl';
      default:
        return '서버 $actionLabel 실패\n$requestUrl\n${e.message ?? e.type}';
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is! Map) return null;
    for (final key in ['message', 'detail', 'error']) {
      final value = data[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  /// 010 - 1234 - 5678 / 010-1234-5678 → 01012345678
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 1992-10-31 / 1992.10.31 / 921031 / 19921031 → YYYY-MM-DD 우선
  String _normalizeBirthDate(String birthDate) {
    final raw = birthDate.trim();
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
      return raw;
    }

    if (digits.length == 8) {
      // YYYYMMDD → YYYY-MM-DD
      return '${digits.substring(0, 4)}-${digits.substring(4, 6)}-${digits.substring(6, 8)}';
    }

    if (digits.length == 6) {
      // YYMMDD → 19xx/20xx 추정
      final yy = int.parse(digits.substring(0, 2));
      final year = yy >= 50 ? 1900 + yy : 2000 + yy;
      return '$year-${digits.substring(2, 4)}-${digits.substring(4, 6)}';
    }

    return raw;
  }

  @override
  Future<LoginResponse> refreshToken() async {
    throw UnimplementedError();
  }

  @override
  Future<LoginResponse> signupWithKakao({
    required String signupToken,
    required String phone,
    required String birthDate,
    String? name,
  }) async {
    final requestUrl = '${AppConfig.apiBaseUrl}${ApiEndpoints.kakaoSignup}';
    final normalizedPhone = _normalizePhone(phone);
    final normalizedBirth = _normalizeBirthDate(birthDate);
    final normalizedName = name?.trim() ?? '';

    if (normalizedName.isEmpty) {
      throw Exception('이름을 입력해주세요.');
    }
    if (normalizedPhone.length < 10 || normalizedPhone.length > 11) {
      throw Exception('전화번호 형식이 올바르지 않습니다. (예: 01012345678)');
    }

    debugPrint('Backend signup request: POST $requestUrl');
    debugPrint(
      'signup payload: phone=$normalizedPhone, birthDate=$normalizedBirth, '
      'name=$normalizedName',
    );

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoSignup,
        data: {
          'signupToken': signupToken,
          'phone': normalizedPhone,
          'birthDate': normalizedBirth,
          'name': normalizedName,
        },
      );

      return _parseLoginResponse(response.data);
    } on DioException catch (e) {
      debugPrint(
        'Kakao signup failed: type=${e.type}, '
        'status=${e.response?.statusCode}, url=$requestUrl, '
        'data=${e.response?.data}',
      );
      throw Exception(
        _mapDioError(e, requestUrl, actionLabel: '회원가입'),
      );
    }
  }

  @override
  Future<void> logout() async {
    await UserApi.instance.logout();
  }
}
