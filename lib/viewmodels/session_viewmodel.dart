import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/utils/auth_errors.dart';
import '../data/models/models.dart';
import '../data/repositories/app_repository.dart';
import 'base_viewmodel.dart';

class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._authRepository);

  final AuthRepository _authRepository;

  UserAccount? user;
  Business? business;
  bool initialized = false;

  StreamSubscription<User?>? _authSubscription;
  int _authSyncDepth = 0;

  bool get isLoggedIn => user != null;

  Future<void> init() async {
    await _authRepository.waitForAuthReady();
    _authSubscription = _authRepository.authStateChanges.listen(
      (_) => unawaited(_syncSession()),
    );
    try {
      await _syncSession().timeout(const Duration(seconds: 10));
    } on TimeoutException {
      user = null;
      business = null;
    }
    initialized = true;
    notifyListeners();
  }

  Future<T> _duringAuthMutation<T>(Future<T> Function() action) async {
    _authSyncDepth++;
    try {
      return await action();
    } finally {
      _authSyncDepth--;
    }
  }

  Future<void> _syncSession() async {
    if (_authSyncDepth > 0) {
      return;
    }
    if (_authRepository.currentUser == null) {
      user = null;
      business = null;
      notifyListeners();
      return;
    }

    try {
      final session = await _authRepository.loadCurrentSession();
      if (session == null) {
        user = null;
        business = null;
      } else {
        user = session.user;
        business = session.business;
      }
    } on Object {
      user = null;
      business = null;
    }
    notifyListeners();
  }

  Future<void> applySession({
    required UserAccount user,
    required Business business,
  }) async {
    this.user = user;
    this.business = business;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _duringAuthMutation(() async {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );
      await applySession(user: result.user, business: result.business);
    });
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String businessName,
    required String email,
    required String password,
  }) async {
    await _duringAuthMutation(() async {
      final result = await _authRepository.signUp(
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        email: email,
        password: password,
      );
      await applySession(user: result.user, business: result.business);
    });
  }

  Future<void> signInWithGoogle() async {
    await _duringAuthMutation(() async {
      final result = await _authRepository.signInWithGoogle();
      await applySession(user: result.user, business: result.business);
    });
  }

  void updateBusiness(Business value) {
    business = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    user = null;
    business = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

class SignInViewModel extends BaseViewModel {
  SignInViewModel(this._session);

  final SessionViewModel _session;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  String? emailError;
  String? passwordError;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  bool get canSubmit =>
      emailController.text.trim().isNotEmpty &&
      passwordController.text.isNotEmpty;

  Future<bool> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    emailError = email.contains('@') ? null : 'Enter a valid business email.';
    passwordError =
        password.length < 6 ? 'Password must be at least 6 characters.' : null;
    notifyListeners();
    if (emailError != null || passwordError != null) {
      return false;
    }

    setBusy(true);
    setError(null);
    try {
      await _session.signIn(email: email, password: password);
      return true;
    } on Object catch (error) {
      setError(AuthErrors.message(error));
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> continueWithGoogle() async {
    setBusy(true);
    setError(null);
    try {
      await _session.signInWithGoogle();
      return true;
    } on Object catch (error) {
      setError(AuthErrors.message(error));
      return false;
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class SignUpViewModel extends BaseViewModel {
  SignUpViewModel(this._session);

  final SessionViewModel _session;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? firstNameError;
  String? lastNameError;
  String? businessNameError;
  String? emailError;
  String? passwordError;
  String? confirmError;

  void clearFirstNameError() {
    firstNameError = null;
    notifyListeners();
  }

  void clearLastNameError() {
    lastNameError = null;
    notifyListeners();
  }

  void clearBusinessNameError() {
    businessNameError = null;
    notifyListeners();
  }

  void clearEmailError() {
    emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    passwordError = null;
    notifyListeners();
  }

  void clearConfirmError() {
    confirmError = null;
    notifyListeners();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<bool> submit() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final businessName = businessNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    firstNameError = firstName.isEmpty ? 'Enter your first name.' : null;
    lastNameError = lastName.isEmpty ? 'Enter your last name.' : null;
    businessNameError =
        businessName.isEmpty ? 'Enter your business name.' : null;
    emailError = email.isEmpty
        ? 'Enter your business email.'
        : email.contains('@')
            ? null
            : 'Enter a valid business email.';
    passwordError = password.isEmpty
        ? 'Enter a password.'
        : password.length < 8
            ? 'Create a password with at least 8 characters.'
            : null;
    confirmError = confirmPassword.isEmpty
        ? 'Confirm your password.'
        : confirmPassword == password
            ? null
            : 'Passwords do not match.';
    notifyListeners();
    if ([
      firstNameError,
      lastNameError,
      businessNameError,
      emailError,
      passwordError,
      confirmError,
    ].any((error) => error != null)) {
      return false;
    }

    setBusy(true);
    setError(null);
    try {
      await _session.signUp(
        firstName: firstName,
        lastName: lastName,
        businessName: businessName,
        email: email,
        password: password,
      );
      return true;
    } on Object catch (error) {
      setError(AuthErrors.message(error));
      return false;
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    businessNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class ForgotPasswordViewModel extends BaseViewModel {
  ForgotPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  String email = '';
  String? emailError;
  bool sent = false;

  void updateEmail(String value) {
    email = value;
    emailError = null;
    notifyListeners();
  }

  Future<void> submit() async {
    emailError = email.contains('@') ? null : 'Enter a valid business email.';
    notifyListeners();
    if (emailError != null) {
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await _authRepository.sendResetEmail(email);
      sent = true;
    } on Object catch (error) {
      setError(AuthErrors.message(error));
    } finally {
      setBusy(false);
    }
  }
}
