import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:split_mate/features/auth/controller/auth_controller.dart';
import 'package:split_mate/features/auth/repository/auth_repository.dart';
import 'package:split_mate/models/user_model.dart';

void main() {
  group('Splitwise Authentication System Testing', () {
    // Simulated authentication database
    final List<UserModel> users = [];

    // Helper function to simulate user creation
    UserModel createUser(String email, String password) {
      // Validate password strength
      if (password.length < 6) {
        throw Exception('Weak password');
      }

      // Check for existing email
      if (users.any((user) => user.email == email)) {
        throw Exception('Email already in use');
      }

      final userModel = UserModel(
        username: email.split('@')[0],
        name: email.split('@')[0],
        profilePic: 'default_avatar',
        uid: users.length.toString(),
        isAuthenticated: true,
        friendsList: [],
        email: email,
      );

      users.add(userModel);
      return userModel;
    }

    // Helper function to simulate login
    UserModel? loginUser(String email, String password) {
      try {
        final user = users.firstWhere(
          (user) => user.email == email,
        );
        
        return user;
      } catch (e) {
        throw Exception('User not found');
      }
    }

    group('Authentication Login Tests', () {
      test('Should successfully login with valid credentials', () {
        final testUser = createUser('test@example.com', 'strongpassword123');
        
        final loggedInUser = loginUser('test@example.com', 'strongpassword123');
        
        expect(loggedInUser, isNotNull);
        expect(loggedInUser?.email, 'test@example.com');
        expect(loggedInUser?.isAuthenticated, true);
      });

      test('Should throw exception for non-existent user', () {
        expect(
          () => loginUser('nonexistent@example.com', 'anypassword'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Authentication Sign Up Tests', () {
      test('Should successfully create a new user account', () {
        final newUser = createUser('newuser@example.com', 'securePassword123');
        
        expect(newUser, isNotNull);
        expect(newUser.email, 'newuser@example.com');
        expect(newUser.isAuthenticated, true);
      });

      test('Should throw exception for weak password', () {
        expect(
          () => createUser('weakpass@example.com', '123'),
          throwsA(isA<Exception>()),
        );
      });

      test('Should throw exception for existing email', () {
        createUser('duplicate@example.com', 'password123');
        
        expect(
          () => createUser('duplicate@example.com', 'anotherpassword'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}