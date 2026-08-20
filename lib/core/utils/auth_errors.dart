import 'package:firebase_auth/firebase_auth.dart';

abstract final class AuthErrors {
  static String message(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => 'Enter a valid business email.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Invalid email or password.',
        'email-already-in-use' => 'An account already exists with this email.',
        'weak-password' => 'Password is too weak. Use at least 8 characters.',
        'operation-not-allowed' =>
          'Email sign-up is not enabled. Contact support.',
        'too-many-requests' =>
          'Too many attempts. Wait a moment and try again.',
        'channel-error' =>
          'Authentication is still starting. Refresh the page and try again.',
        _ => _authMessage(error),
      };
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'profile-not-found' =>
          'Account profile not found. Create a new account to continue.',
        'business-not-found' || 'business-not-linked' =>
          'Business profile not found for this account.',
        'permission-denied' =>
          'Could not save your account. Try again or contact support.',
        _ => error.message ?? 'Unable to load data from Firebase.',
      };
    }
    return 'Something went wrong. Try again.';
  }

  static String _authMessage(FirebaseAuthException error) {
    final raw = error.message ?? '';
    if (raw.contains('FirebaseAuthHostApi') || raw.contains('channel-error')) {
      return 'Authentication is still starting. Refresh the page and try again.';
    }
    return raw.isEmpty ? 'Authentication failed. Try again.' : raw;
  }
}
