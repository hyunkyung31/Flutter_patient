import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_remote_datasource.dart';
import '../model/login_response.dart';

class KakaoAuthService implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> loginWithKakao() async {
    final token = await _loginWithKakaoSdk();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoLogin,
        data: {
          'accessToken': token.accessToken,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('서버 응답 형식이 올바르지 않습니다.');
      }

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Kakao backend login failed: type=${e.type}, status=${e.response?.statusCode}');
      throw Exception(_mapDioError(e));
    }
  }

  Future<OAuthToken> _loginWithKakaoSdk() async {
    if (kDebugMode) {
      // Register this value in Kakao Developers Console > Android key hash.
      debugPrint('Kakao key hash (KakaoSdk.origin): ${await KakaoSdk.origin}');
    }

    final installed = await isKakaoTalkInstalled();

    if (!installed) {
      try {
        return await UserApi.instance.loginWithKakaoAccount();
      } catch (e) {
        debugPrint('Kakao account login failed: $e');
        throw Exception('카카오 로그인에 실패했습니다.');
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
        throw Exception('카카오 로그인에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('KakaoTalk login failed: $e');
      throw Exception('카카오 로그인에 실패했습니다.');
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return '서버에 연결할 수 없습니다. API_BASE_URL을 확인해주세요.';
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        return '서버 로그인에 실패했습니다. (${e.response?.statusCode ?? 'error'})';
      default:
        return '서버 로그인에 실패했습니다.';
    }
  }

  @override
  Future<LoginResponse> refreshToken() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    await UserApi.instance.logout();
  }
}
