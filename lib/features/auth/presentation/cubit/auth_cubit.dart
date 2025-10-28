import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final CheckAuthStatus checkAuthStatus;
  final GetCurrentUser getCurrentUser;

  AuthCubit({
    required this.signInWithGoogle,
    required this.signOut,
    required this.checkAuthStatus,
    required this.getCurrentUser,
  }) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());

    final result = await checkAuthStatus(NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (isSignedIn) async {
        if (isSignedIn) {
          final userResult = await getCurrentUser(NoParams());
          userResult.fold(
            (failure) => emit(const AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user)),
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signIn() async {
    emit(AuthLoading());

    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
