import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? code;

  const ServerFailure({required super.message, this.statusCode, this.code});

  @override
  List<Object?> get props => [message, statusCode, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class ValidationFailure extends Failure {
  final List<Map<String, dynamic>> errors;

  const ValidationFailure({required super.message, this.errors = const []});

  @override
  List<Object?> get props => [message, errors];
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
