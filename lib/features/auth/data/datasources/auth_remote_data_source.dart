import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({required this.googleSignIn});

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign-In...', name: 'AuthAPI');

      final account = await googleSignIn.signIn();

      if (account == null) {
        developer.log('Google Sign-In cancelled by user', name: 'AuthAPI');
        throw AuthException('Sign in cancelled');
      }

      developer.log('Google Sign-In successful: ${account.email}',
          name: 'AuthAPI');

      return UserModel(
        email: account.email,
        name: account.displayName ?? '',
        photoUrl: account.photoUrl ?? '',
      );
    } catch (e) {
      developer.log('Google Sign-In error: $e', name: 'AuthAPI');
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      developer.log('Signing out...', name: 'AuthAPI');
      await googleSignIn.signOut();
      developer.log('Sign out successful', name: 'AuthAPI');
    } catch (e) {
      developer.log('Sign out error: $e', name: 'AuthAPI');
      throw AuthException('Failed to sign out');
    }
  }
}
