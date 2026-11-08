class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final List<dynamic>? errors;

  const ServerException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode, code: $code)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({required this.message});

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

class ValidationException implements Exception {
  final String message;
  final List<Map<String, dynamic>> errors;

  const ValidationException({required this.message, required this.errors});

  @override
  String toString() =>
      'ValidationException(message: $message, errors: $errors)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}
