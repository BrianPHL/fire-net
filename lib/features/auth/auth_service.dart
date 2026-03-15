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
}
