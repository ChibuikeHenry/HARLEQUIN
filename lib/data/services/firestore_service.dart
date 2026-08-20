import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import '../firestore/firestore_mapper.dart';
import '../firestore/firestore_paths.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestorePaths.users);

  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection(FirestorePaths.businesses);

  CollectionReference<Map<String, dynamic>> _submissions(String businessId) =>
      _businesses.doc(businessId).collection(FirestorePaths.submissions);

  Future<({UserAccount user, Business business})> createAccountProfile({
    required User firebaseUser,
    required String firstName,
    required String lastName,
    required String businessName,
    required String email,
  }) async {
    final businessRef = _businesses.doc();
    final slug = slugFromBusinessName(businessName);
    final uniqueLink = uniqueLinkForSlug(slug);
    final formattedName =
        businessName.endsWith('.') ? businessName : '$businessName.';

    final batch = _firestore.batch();

    batch.set(
      businessRef,
      FirestoreMapper.businessToMap(
        ownerId: firebaseUser.uid,
        name: formattedName,
        email: email,
        phone: '',
        uniqueLink: uniqueLink,
        slug: slug,
        isCreate: true,
      ),
    );

    batch.set(
      _users.doc(firebaseUser.uid),
      FirestoreMapper.userToMap(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: 'Customer Care',
        businessId: businessRef.id,
        isCreate: true,
      ),
    );

    await batch.commit();
    return loadSession(firebaseUser);
  }

  Future<({UserAccount user, Business business})> loadSession(
    User firebaseUser,
  ) async {
    final userDoc = await _users.doc(firebaseUser.uid).get();
    if (!userDoc.exists || userDoc.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'profile-not-found',
        message: 'Account profile not found. Sign up again or contact support.',
      );
    }

    final user = FirestoreMapper.userFromDoc(firebaseUser.uid, userDoc.data()!);
    if (user.businessId.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'business-not-linked',
        message: 'This account is not linked to a business.',
      );
    }

    final businessDoc = await _businesses.doc(user.businessId).get();
    if (!businessDoc.exists || businessDoc.data() == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'business-not-found',
        message: 'Business profile not found.',
      );
    }

    final business =
        FirestoreMapper.businessFromDoc(user.businessId, businessDoc.data()!);

    return (user: user, business: business);
  }

  Future<Business> updateBusiness(Business business) async {
    await _businesses.doc(business.id).update({
      FirestoreFields.name: business.name,
      FirestoreFields.email: business.email,
      FirestoreFields.phone: business.phone,
      FirestoreFields.uniqueLink: business.uniqueLink,
      FirestoreFields.slug: business.slug.isEmpty
          ? slugFromBusinessName(business.name)
          : business.slug,
      FirestoreFields.logoUrl: business.logoUrl,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
    return business.copyWith(
      slug: business.slug.isEmpty
          ? slugFromBusinessName(business.name)
          : business.slug,
    );
  }

  Future<String> saveUniqueLink({
    required String businessId,
    required String link,
  }) async {
    final trimmed = link.trim();
    await _businesses.doc(businessId).update({
      FirestoreFields.uniqueLink: trimmed,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    });
    return trimmed;
  }

  Future<List<Submission>> fetchSubmissions(String businessId) async {
    final snapshot = await _submissions(businessId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => FirestoreMapper.submissionFromDoc(doc.id, doc.data()))
        .toList();
  }

  Future<DashboardStats> fetchStats(String businessId) async {
    final submissions = await fetchSubmissions(businessId);
    return StatsCalculator.fromSubmissions(submissions);
  }

  Future<void> addSubmission({
    required String businessId,
    required SubmissionType type,
    required String customerName,
    required String subject,
    SubmissionStatus status = SubmissionStatus.inProgress,
    String channel = 'web',
  }) async {
    await _submissions(businessId).add(
      FirestoreMapper.submissionToMap(
        type: type,
        customerName: customerName,
        subject: subject,
        status: status,
        channel: channel,
        isCreate: true,
      ),
    );
  }
}
