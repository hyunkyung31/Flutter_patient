import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_remote_datasource.dart';
import '../model/login_response.dart';

class KakaoAuthService implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> loginWithKakao() async {
    try {
      final token = await _loginWithKakaoSdk();

      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoLogin,
        data: {
          "accessToken": token.accessToken,
        },
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message']?.toString() : null;
      throw Exception(message ?? '로그인에 실패했습니다.');
    }
  }

  Future<OAuthToken> _loginWithKakaoSdk() async {
    final installed = await isKakaoTalkInstalled();

    if (!installed) {
      return UserApi.instance.loginWithKakaoAccount();
    }

    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (e) {
      // 사용자가 직접 취소한 경우는 fallback하지 않는다.
      if (e.code == 'CANCELED') rethrow;
      return UserApi.instance.loginWithKakaoAccount();
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
