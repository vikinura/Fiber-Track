import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final List<Map<String, dynamic>>? validationErrors;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.validationErrors,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    List<Map<String, dynamic>>? validationErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      validationErrors: validationErrors,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, validationErrors];
}
