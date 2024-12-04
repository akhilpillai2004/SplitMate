import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:split_mate/core/constants/constants.dart'; // Default avatar constant
import 'package:split_mate/core/constants/firebase_constants.dart'; // Firebase constants
import 'package:split_mate/core/failure.dart';
import 'package:split_mate/core/providers/firebase_providers.dart';
import 'package:split_mate/core/type_defs.dart';
import 'package:split_mate/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential = await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          username: userCredential.user!.email?.split('@')[0] ?? 'No Username',
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: Constants.avatarDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          //splitBalance: 0.0,
          friendsList: [],
          email: userCredential.user!.email ?? 'No email',
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase Error'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error during logout: $e");
      rethrow;
    }
  }

  FutureEither<UserModel> signUpWithEmail(String email, String password) async {
  try {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create a complete UserModel
    final userModel = UserModel(
      username: email.split('@')[0],
      name: email.split('@')[0],
      profilePic: Constants.avatarDefault,
      uid: userCredential.user!.uid,
      isAuthenticated: true,
      //splitBalance: 0.0,
      friendsList: [],
      email: email,
    );

    // Save user to Firestore
    await _users.doc(userCredential.user!.uid).set(userModel.toMap());

    return right(userModel);
  } on FirebaseAuthException catch (e) {
    return left(Failure(e.message ?? 'Sign-up failed.'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}



FutureEither<UserModel> signInWithEmail(String email, String password) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    UserModel userModel = await getUserData(userCredential.user!.uid).first;
    return right(userModel);
  } on FirebaseAuthException catch (e) {
    return left(Failure(e.message ?? 'Login failed.'));
  } catch (e) {
    return left(Failure(e.toString()));
  }
}

}
