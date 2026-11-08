import 'package:dio/dio.dart';

import 'token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._tokenStorage, {this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Clear invalid token upon 401 response
      await _tokenStorage.clearToken();
      onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
