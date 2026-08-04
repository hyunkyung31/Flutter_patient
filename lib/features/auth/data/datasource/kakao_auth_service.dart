import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'auth_remote_datasource.dart';
import '../model/login_response.dart';

class KakaoAuthService implements AuthRemoteDataSource {
  @override
  Future<LoginResponse> loginWithKakao() async {
    debugPrint("===== Kakao Login Start =====");

    try {
      OAuthToken token;

      final installed = await isKakaoTalkInstalled();
      debugPrint("카카오톡 설치 여부 : $installed");

      if (installed) {
        debugPrint("카카오톡 로그인 시도");
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        debugPrint("카카오계정(Web) 로그인 시도");
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      debugPrint("카카오 로그인 성공");
      debugPrint("AccessToken : ${token.accessToken}");

      debugPrint("Django 요청 시작");

      final response = await ApiClient.dio.post(
        ApiEndpoints.kakaoLogin,
        data: {
          "accessToken": token.accessToken,
        },
      );

      debugPrint("Django 응답 성공");
      debugPrint(response.data.toString());

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("===== DioException =====");
      debugPrint(e.toString());

      if (e.response != null) {
        debugPrint("Status : ${e.response!.statusCode}");
        debugPrint("Body : ${e.response!.data}");
      }

      rethrow;
    } catch (e, s) {
      debugPrint("===== Kakao Login Error =====");
      debugPrint(e.toString());
      debugPrint(s.toString());

      rethrow;
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