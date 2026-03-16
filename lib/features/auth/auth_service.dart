import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  bool _isRetryableFirestoreError(String code) {
    return code == 'unauthenticated' ||
        code == 'unavailable' ||
        code == 'deadline-exceeded' ||
        code == 'aborted' ||
        code == 'unknown' ||
        code == 'internal';
  }

  Future<void> _writeUserProfileWithRetry({
    required String uid,
    required Map<String, dynamic> profilePayload,
    int maxAttempts = 3,
  }) async {
    FirebaseException? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await _usersCollection.doc(uid).set(
          profilePayload,
          SetOptions(merge: true),
        );
        return;
      } on FirebaseException catch (error) {
        lastError = error;
        if (!_isRetryableFirestoreError(error.code) || attempt == maxAttempts) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 250 * attempt));
      }
    }

    throw lastError ??
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unknown',
          message: 'User profile write failed for an unknown reason.',
        );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final selectedRole = role.trim().toLowerCase();
    if (selectedRole != 'user' && selectedRole != 'engineer') {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Unsupported role selected.',
      );
    }

    final uid = userCredential.user?.uid;
    if (uid == null || uid.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-user-id',
        message: 'Unable to resolve user id for this account.',
      );
    }

    final profilePayload = {
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'role': selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _writeUserProfileWithRetry(
        uid: uid,
        profilePayload: profilePayload,
      );
    } on FirebaseException catch (error) {
      if (!_isRetryableFirestoreError(error.code)) {
        try {
          await userCredential.user?.delete();
        } catch (_) {
        }
      }

      throw FirebaseAuthException(
        code: 'profile-save-failed',
        message:
            'Unable to save user profile [${error.code}] ${error.message ?? ''}',
      );
    }

    if (name.trim().isNotEmpty) {
      try {
        await userCredential.user?.updateDisplayName(name.trim());
        await userCredential.user?.reload();
      } catch (_) {
      }
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> getRoleForUser({String? uid}) async {
    final userId = uid ?? _firebaseAuth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-user-id',
        message: 'No authenticated user id found.',
      );
    }

    final snapshot = await _usersCollection.doc(userId).get();
    final data = snapshot.data();
    final role = (data?['role'] as String?)?.trim().toLowerCase();

    if (role == 'engineer' || role == 'user') {
      return role!;
    }

    return 'user';
  }

  static String getLoginErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  static String getRegisterErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-role':
        return 'Please select either User or Engineer.';
      case 'operation-not-allowed':
        return 'Registration is currently unavailable. Please contact support.';
      case 'profile-save-failed':
      case 'missing-user-id':
        return 'Account created, but profile setup failed. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Registration failed. Please try again.';
    }
  }
}
