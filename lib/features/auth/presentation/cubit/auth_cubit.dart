import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentSession getCurrentSessionUseCase;
  final LoginUser loginUserUseCase;
  final RegisterUser registerUserUseCase;
  final Logout logoutUseCase;

  AuthCubit({
    required this.getCurrentSessionUseCase,
    required this.loginUserUseCase,
    required this.registerUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState());

  /// Checks the active session on app startup (used by SplashPage).
  Future<void> checkSession() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final session = await getCurrentSessionUseCase();
      if (session != null && session.user != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: session.user,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            clearError: true,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          clearError: true,
        ),
      );
    }
  }

  /// Logs in a user with username and password.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await loginUserUseCase(
        username: username,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Registers a new user and logs them in immediately.
  Future<void> register({
    required String name,
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await registerUserUseCase(
        name: name,
        username: username,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Clears active session and logs out user.
  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await logoutUseCase();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Clears any user-facing error message in state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
