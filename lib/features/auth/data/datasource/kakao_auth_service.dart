import 'package:dio/dio.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_remote_datasource.dart';
import '../model/login_response.dart';

class KakaoAuthService implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> loginWithKakao() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoLogin,
        data: {'accessToken': token.accessToken},
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Login failed');
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
