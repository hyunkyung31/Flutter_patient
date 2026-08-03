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

      final data = response.data;
      if (data is! Map) {
        throw Exception(
          '서버 응답 형식이 올바르지 않습니다. (${data.runtimeType})',
        );
      }

      return LoginResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      debugPrint(
        'Kakao backend login failed: type=${e.type}, '
        'status=${e.response?.statusCode}, url=$requestUrl, '
        'data=${e.response?.data}',
      );
      throw Exception(_mapDioError(e, requestUrl));
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
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return '서버 $actionLabel 실패 (${e.response?.statusCode})\n${data['message']}';
        }
        return '서버 $actionLabel 실패 (${e.response?.statusCode})\n$requestUrl';
      default:
        return '서버 $actionLabel 실패\n$requestUrl\n${e.message ?? e.type}';
    }
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
    // 서버 매칭용: 숫자만 전송 (010 - 1234 - 5678 → 01012345678)
    final normalizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalizedBirth = birthDate.trim();
    final normalizedName = name?.trim();

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
          // 백엔드에서 name 필수로 받는 경우 대비해 항상 전달
          'name': normalizedName ?? '',
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('서버 응답 형식이 올바르지 않습니다. (${data.runtimeType})');
      }

      return LoginResponse.fromJson(Map<String, dynamic>.from(data));
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
