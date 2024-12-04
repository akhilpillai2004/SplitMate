import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:split_mate/core/utils.dart';
import 'package:split_mate/features/auth/repository/auth_repository.dart';
import 'package:split_mate/models/user_model.dart';
import 'package:split_mate/features/home/screens/pre_home_screen.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Future<void> signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    try {
      final user = await _authRepository.signInWithGoogle(isFromLogin);
      state = false;

      user.fold(
        (failure) => showSnackBar(context, failure.message),
        (userModel) {
          _ref.read(userProvider.notifier).state = userModel;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreHomeScreen()),
          );
        },
      );
    } catch (e) {
      state = false;
      print('Error during Google sign-in: $e');
      showSnackBar(context, 'Google sign-in failed. Please try again.');
    }
  }

  Future<void> signUpWithEmail(
    BuildContext context, String email, String password) async {
  state = true; // Set loading state
  try {
    // Call the repository's signUpWithEmail method
    final user = await _authRepository.signUpWithEmail(email, password);

    // Reset loading state
    state = false;

    // Handle the result
    user.fold(
      // Handle failure
      (failure) {
        showSnackBar(context, failure.message);
      },
      // Handle success
      (userModel) {
        // Save user to the state provider
        _ref.read(userProvider.notifier).state = userModel;

        // Navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PreHomeScreen()),
        );
      },
    );
  } catch (e) {
    // Handle unexpected errors
    state = false;
    print('Error during email sign-up: $e');
    showSnackBar(context, 'Email sign-up failed. Please try again.');
  }
}


Future<void> signInWithEmail(
    BuildContext context, String email, String password) async {
  state = true;
  try {
    final user = await _authRepository.signInWithEmail(email, password);
    state = false;

    user.fold(
      (failure) => showSnackBar(context, failure.message),
      (userModel) {
        _ref.read(userProvider.notifier).state = userModel;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PreHomeScreen()),
        );
      },
    );
  } catch (e) {
    state = false;
    print('Error during email login: $e');
    showSnackBar(context, 'Invalid credentials. Please try again.');
  }
}


  Future<void> logout(BuildContext context) async {
    try {
      await _authRepository.logOut();
      _ref.read(userProvider.notifier).state = null;
      showSnackBar(context, 'Logged out successfully.');
    } catch (e) {
      print('Logout error: $e');
      showSnackBar(context, 'Logout failed. Please try again.');
    }
  }
}
