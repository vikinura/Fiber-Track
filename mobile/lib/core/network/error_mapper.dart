import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

Failure mapExceptionToFailure(Exception exception) {
  if (exception is ServerException) {
    return ServerFailure(
      message: exception.message,
      statusCode: exception.statusCode,
      code: exception.code,
    );
  } else if (exception is NetworkException) {
    return NetworkFailure(message: exception.message);
  } else if (exception is UnauthorizedException) {
    return UnauthorizedFailure(message: exception.message);
  } else if (exception is ValidationException) {
    return ValidationFailure(
      message: exception.message,
      errors: exception.errors,
    );
  } else if (exception is CacheException) {
    return CacheFailure(message: exception.message);
  }
  return ServerFailure(message: exception.toString());
}

Exception mapDioErrorToException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException(
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String message = 'Terjadi kesalahan pada server';
      String? code;
      List<Map<String, dynamic>> errors = [];

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          message = data['message'].toString();
        }
        if (data['code'] != null) {
          code = data['code'].toString();
        }
        if (data['errors'] != null && data['errors'] is List) {
          errors = (data['errors'] as List)
              .filterMap((e) => e is Map<String, dynamic> ? e : null)
              .toList();
        }
      }

      if (statusCode == 401) {
        return UnauthorizedException(message: message);
      } else if (statusCode == 422) {
        return ValidationException(message: message, errors: errors);
      }

      return ServerException(
        message: message,
        statusCode: statusCode,
        code: code,
        errors: errors,
      );
    case DioExceptionType.cancel:
      return const NetworkException(message: 'Permintaan dibatalkan');
    default:
      return ServerException(
        message: error.message ?? 'Terjadi kesalahan yang tidak terduga',
      );
  }
}

extension _IterableFilterMap<E> on Iterable<E> {
  Iterable<T> filterMap<T>(T? Function(E e) f) sync* {
    for (final e in this) {
      final t = f(e);
      if (t != null) yield t;
    }
  }
}
