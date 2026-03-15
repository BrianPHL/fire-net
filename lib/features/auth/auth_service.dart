import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

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

    // Role is currently used by the client flow for post-register routing.
    // Persisting role server-side should be done with a backend/Firestore record.
    final selectedRole = role.trim().toLowerCase();
    if (selectedRole != 'user' && selectedRole != 'engineer') {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Unsupported role selected.',
      );
    }

    // Profile update should not block successful account creation.
    if (name.trim().isNotEmpty) {
      try {
        await userCredential.user?.updateDisplayName(name.trim());
        await userCredential.user?.reload();
      } catch (_) {
        // Ignore profile update errors and keep the newly created account signed in.
      }
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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
      case 'operation-not-allowed':
        return 'Email/password sign up is not enabled.';
      case 'unauthorized-domain':
        return 'This web domain is not authorized in Firebase.';
      case 'app-not-authorized':
      case 'invalid-api-key':
        return 'Firebase app configuration is invalid for this platform.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-role':
        return 'Please select either User or Engineer.';
      case 'weak-password':
        return 'Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Registration failed (${exception.code}). Please try again.';
    }
  }
}
