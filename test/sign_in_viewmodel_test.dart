import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harlequin/core/utils/auth_errors.dart';

void main() {
  test('maps invalid credential to a friendly message', () {
    final error = FirebaseAuthException(code: 'invalid-credential');
    expect(
      AuthErrors.message(error),
      'Invalid email or password.',
    );
  });

  test('maps channel-error to a friendly message', () {
    final error = FirebaseAuthException(
      code: 'channel-error',
      message:
          'dev.flutter.pigeon.firebase_auth_platform_interface.FirebaseAuthHostApi.createUserWithEmailAndPassword',
    );
    expect(
      AuthErrors.message(error),
      'Authentication is still starting. Refresh the page and try again.',
    );
  });
}
