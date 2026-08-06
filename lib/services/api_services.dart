import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

/// 기존 ApiClient를 그대로 쓰는 호환 진입점.
/// (인터셉터·토큰 갱신 포함)
class ApiService {
  ApiService._();

  static Dio get dio => ApiClient.dio;
}
