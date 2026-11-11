import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';

/// Turns a Firebase Auth error into a message that is safe to show.
/// Only the auth repository calls this.
AppException authExceptionFrom(FirebaseAuthException e) {
  final message = switch (e.code) {
    'invalid-email' => 'That email address is not valid.',
    // Newer Firebase returns invalid-credential for both a wrong password
    // and an unknown email, so we do not say which one it was.
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Incorrect email or password.',
    'user-disabled' => 'This account has been disabled.',
    'email-already-in-use' => 'An account with this email already exists.',
    'weak-password' => 'Choose a stronger password (at least 6 characters).',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'network-request-failed' => 'No internet connection. Check it and retry.',
    'operation-not-allowed' => 'Email sign-in is not enabled yet.',
    _ => 'Something went wrong. Please try again.',
  };
  return AppException(message);
}
