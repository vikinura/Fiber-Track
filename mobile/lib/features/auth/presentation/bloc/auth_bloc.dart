import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final GetCurrentUser getCurrentUser;
  final Logout logout;

  AuthBloc({
    required this.login,
    required this.getCurrentUser,
    required this.logout,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginSubmitted>(_onAuthLoginSubmitted);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getCurrentUser();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            errorMessage: null,
          ),
        );
      },
      (user) {
        if (user.role == 'super_admin') {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              user: null,
              errorMessage: AppStrings.superAdminBlockedMessage,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              errorMessage: null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onAuthLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: null,
        validationErrors: null,
      ),
    );

    final result = await login(email: event.email, password: event.password);

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              errorMessage: failure.message,
              validationErrors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (user) {
        if (user.role == 'super_admin') {
          // Reject super_admin on mobile application
          add(AuthLogoutRequested());
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              user: null,
              errorMessage: AppStrings.superAdminBlockedMessage,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              errorMessage: null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await logout();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        validationErrors: null,
      ),
    );
  }
}
