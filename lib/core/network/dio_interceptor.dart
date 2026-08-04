import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

/// - 요청에 Bearer access token 부착
/// - 401 시 refresh 1회 시도 후 재요청
class DioInterceptor extends Interceptor {
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 로그인/회원가입/리프레시는 토큰 없이
    final path = options.path;
    final skipAuth = path.contains(ApiEndpoints.kakaoLogin) ||
        path.contains(ApiEndpoints.kakaoSignup) ||
        path.contains(ApiEndpoints.refresh) ||
        path.contains('/api/login/');

    if (!skipAuth) {
      final token = await SecureStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final path = err.requestOptions.path;
    if (path.contains(ApiEndpoints.refresh) ||
        path.contains(ApiEndpoints.kakaoLogin) ||
        path.contains(ApiEndpoints.kakaoSignup)) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refresh = await SecureStorageService.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        handler.next(err);
        return;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: err.requestOptions.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final res = await dio.post(
        ApiEndpoints.refresh,
        data: {'refresh': refresh},
      );
      final newAccess = (res.data is Map)
          ? (res.data['access']?.toString() ?? '')
          : '';
      if (newAccess.isEmpty) {
        handler.next(err);
        return;
      }

      await SecureStorageService.saveToken(
        access: newAccess,
        refresh: refresh,
      );

      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $newAccess';
      final clone = await Dio(
        BaseOptions(baseUrl: req.baseUrl),
      ).fetch(req);
      handler.resolve(clone);
    } catch (_) {
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
