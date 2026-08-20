import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirestoreService? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirestoreService();

  final FirebaseAuth _auth;
  final FirestoreService _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Ensures Firebase Auth is initialized (required on web before sign-in/up).
  static Future<void> ensureAuthReady([FirebaseAuth? auth]) async {
    final firebaseAuth = auth ?? FirebaseAuth.instance;
    
    if (kIsWeb) {
      try {
        await firebaseAuth.setPersistence(Persistence.LOCAL);
      } on Object {
        // Persistence may already be configured.
      }
    }

    // Wait for the auth state to settle, which ensures the platform channel is ready.
    try {
      await firebaseAuth
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 20));
      
      // Small additional delay for the Pigeon host API to register fully on web.
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } on TimeoutException {
      debugPrint('Auth initialization timed out, proceeding anyway.');
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    }
  }

  /// @deprecated Use [ensureAuthReady] — kept for call-site compatibility.
  Future<void> waitForAuthReady() => ensureAuthReady(_auth);

  Future<({UserAccount user, Business business})> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    return _firestore.loadSession(firebaseUser);
  }

  Future<({UserAccount user, Business business})> signUp({
    required String firstName,
    required String lastName,
    required String businessName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email and password are required.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'operation-not-allowed');
    }

    try {
      await firebaseUser.updateDisplayName(
        '${firstName.trim()} ${lastName.trim()}'.trim(),
      );
      await firebaseUser.reload();
      await firebaseUser.getIdToken(true);

      return await _firestore.createAccountProfile(
        firebaseUser: firebaseUser,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        businessName: businessName.trim(),
        email: trimmedEmail,
      );
    } on Object {
      await firebaseUser.delete();
      rethrow;
    }
  }

  Future<({UserAccount user, Business business})> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final credential = await _auth.signInWithProvider(provider);
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    return _firestore.loadSession(firebaseUser);
  }

  Future<void> sendResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  Future<({UserAccount user, Business business})?> loadCurrentSession() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return _firestore.loadSession(firebaseUser);
  }
}

class AppRepository {
  AppRepository({
    FirestoreService? firestore,
    StorageService? storage,
  })  : _firestore = firestore ?? FirestoreService(),
        _storage = storage ?? StorageService();

  final FirestoreService _firestore;
  final StorageService _storage;

  Future<DashboardStats> fetchStats(String businessId) =>
      _firestore.fetchStats(businessId);

  Future<List<Submission>> fetchSubmissions(String businessId) =>
      _firestore.fetchSubmissions(businessId);

  Future<Business> updateBusiness(Business business) =>
      _firestore.updateBusiness(business);

  Future<String> uploadBusinessLogo({
    required String businessId,
    required Uint8List bytes,
    required String fileName,
  }) =>
      _storage.uploadBusinessLogo(
        businessId: businessId,
        bytes: bytes,
        fileName: fileName,
      );

  Future<String> saveUniqueLink({
    required String businessId,
    required String link,
  }) =>
      _firestore.saveUniqueLink(businessId: businessId, link: link);

  Future<void> addSubmission({
    required String businessId,
    required SubmissionType type,
    required String customerName,
    required String subject,
  }) =>
      _firestore.addSubmission(
        businessId: businessId,
        type: type,
        customerName: customerName,
        subject: subject,
      );
}
