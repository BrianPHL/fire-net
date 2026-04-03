import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../routes/app_routes.dart';

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

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  String routeForRole(String role) {
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole == 'engineer' || normalizedRole == 'admin') {
      return AppRoutes.engineerDashboard;
    }
    return AppRoutes.userHome;
  }

  Future<bool> hasValidSession({User? user}) async {
    final candidate = user ?? _firebaseAuth.currentUser;
    if (candidate == null) {
      return false;
    }

    try {
      await candidate.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      if (refreshedUser == null) {
        return false;
      }

      await refreshedUser.getIdTokenResult(true);
      return true;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-disabled' ||
          error.code == 'user-not-found' ||
          error.code == 'invalid-user-token' ||
          error.code == 'user-token-expired') {
        await _firebaseAuth.signOut();
      }
      return false;
    } catch (error) {
      debugPrint('Session validation error: $error');
      return false;
    }
  }

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
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('Sign in error: $error');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'An unexpected error occurred during sign in.',
      );
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Validate role
      final selectedRole = role.trim().toLowerCase();
      if (selectedRole != 'user' && selectedRole != 'engineer') {
        throw FirebaseAuthException(
          code: 'invalid-role',
          message: 'Unsupported role selected. Please select either User or Engineer.',
        );
      }

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
            debugPrint('Failed to delete user after Firestore error');
          }
        }

        throw FirebaseAuthException(
          code: 'profile-save-failed',
          message:
              'Account created, but profile setup failed. Please try signing in and we\'ll retry.',
        );
      }

      if (name.trim().isNotEmpty) {
        try {
          await userCredential.user?.updateDisplayName(name.trim());
          await userCredential.user?.reload();
        } catch (error) {
          debugPrint('Failed to update display name: $error');
        }
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('Registration error: $error');
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: 'An unexpected error occurred during registration.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      debugPrint('Sign out error: $error');
      throw FirebaseAuthException(
        code: 'sign-out-failed',
        message: 'Unable to logout. Please try again.',
      );
    }
  }

  Future<String> getRoleForUser({String? uid}) async {
    try {
      final userId = uid ?? _firebaseAuth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-user-id',
          message: 'No authenticated user found.',
        );
      }

      final snapshot = await _usersCollection.doc(userId).get();
      final data = snapshot.data();
      final role = (data?['role'] as String?)?.trim().toLowerCase();

      if (role == 'engineer' || role == 'admin' || role == 'user') {
        return role!;
      }

      return 'user'; // Default role
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('Get role error: $error');
      throw FirebaseAuthException(
        code: 'role-fetch-failed',
        message: 'Unable to fetch user role.',
      );
    }
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
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'unknown-error':
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  static String getRegisterErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Please use a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'invalid-role':
        return 'Please select either User or Engineer role.';
      case 'operation-not-allowed':
        return 'Registration is currently unavailable. Please contact support.';
      case 'profile-save-failed':
      case 'missing-user-id':
        return 'Account created, but profile setup failed. Please try signing in again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'unknown-error':
        return 'An unexpected error occurred. Please try again.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  static String getLogoutErrorMessage(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'sign-out-failed':
        return 'Unable to logout. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Logout failed. Please try again.';
    }
  }
}
