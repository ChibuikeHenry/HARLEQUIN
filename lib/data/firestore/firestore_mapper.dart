import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';
import 'firestore_paths.dart';

class FirestoreMapper {
  static Map<String, dynamic> userToMap({
    required String firstName,
    required String lastName,
    required String email,
    required String role,
    required String businessId,
    required bool isCreate,
  }) {
    return {
      FirestoreFields.firstName: firstName,
      FirestoreFields.lastName: lastName,
      FirestoreFields.email: email,
      FirestoreFields.role: role,
      FirestoreFields.businessId: businessId,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> businessToMap({
    required String ownerId,
    required String name,
    required String email,
    required String phone,
    required String uniqueLink,
    required String slug,
    required bool isCreate,
    String logoUrl = '',
  }) {
    return {
      FirestoreFields.ownerId: ownerId,
      FirestoreFields.name: name,
      FirestoreFields.email: email,
      FirestoreFields.phone: phone,
      FirestoreFields.uniqueLink: uniqueLink,
      FirestoreFields.slug: slug,
      if (logoUrl.isNotEmpty) FirestoreFields.logoUrl: logoUrl,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> submissionToMap({
    required SubmissionType type,
    required String customerName,
    required String subject,
    required SubmissionStatus status,
    required String channel,
    required bool isCreate,
  }) {
    return {
      FirestoreFields.type: _typeToString(type),
      FirestoreFields.customerName: customerName,
      FirestoreFields.subject: subject,
      FirestoreFields.status: _statusToString(status),
      FirestoreFields.channel: channel,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  static UserAccount userFromDoc(String uid, Map<String, dynamic> data) {
    return UserAccount(
      id: uid,
      firstName: data[FirestoreFields.firstName] as String? ?? 'User',
      lastName: data[FirestoreFields.lastName] as String? ?? '',
      email: data[FirestoreFields.email] as String? ?? '',
      role: data[FirestoreFields.role] as String? ?? 'Customer Care',
      businessId: data[FirestoreFields.businessId] as String? ?? '',
    );
  }

  static Business businessFromDoc(String id, Map<String, dynamic> data) {
    final name = data[FirestoreFields.name] as String? ?? 'My Business';
    return Business(
      id: id,
      name: name.endsWith('.') ? name : '$name.',
      email: data[FirestoreFields.email] as String? ?? '',
      phone: data[FirestoreFields.phone] as String? ?? '',
      uniqueLink: data[FirestoreFields.uniqueLink] as String? ?? '',
      slug: data[FirestoreFields.slug] as String? ?? '',
      logoUrl: data[FirestoreFields.logoUrl] as String? ?? '',
      initial: name.isEmpty ? 'B' : name[0].toUpperCase(),
    );
  }

  static Submission submissionFromDoc(String id, Map<String, dynamic> data) {
    final createdAt = data[FirestoreFields.createdAt];
    return Submission(
      id: id,
      type: _typeFromString(data[FirestoreFields.type] as String? ?? 'feedback'),
      customerName: data[FirestoreFields.customerName] as String? ?? 'Anonymous',
      subject: data[FirestoreFields.subject] as String? ?? '',
      status: _statusFromString(data[FirestoreFields.status] as String? ?? 'in_progress'),
      channel: data[FirestoreFields.channel] as String? ?? 'web',
      occurredAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  static String _typeToString(SubmissionType type) => switch (type) {
        SubmissionType.complaint => 'complaint',
        SubmissionType.feedback => 'feedback',
        SubmissionType.compliment => 'compliment',
      };

  static SubmissionType _typeFromString(String value) => switch (value) {
        'complaint' => SubmissionType.complaint,
        'compliment' => SubmissionType.compliment,
        _ => SubmissionType.feedback,
      };

  static String _statusToString(SubmissionStatus status) => switch (status) {
        SubmissionStatus.resolved => 'resolved',
        SubmissionStatus.open => 'open',
        SubmissionStatus.inProgress => 'in_progress',
      };

  static SubmissionStatus _statusFromString(String value) => switch (value) {
        'resolved' => SubmissionStatus.resolved,
        'open' => SubmissionStatus.open,
        _ => SubmissionStatus.inProgress,
      };
}

class StatsCalculator {
  static DashboardStats fromSubmissions(List<Submission> submissions) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month);
    final lastMonthStart = DateTime(now.year, now.month - 1);

    final thisMonth = submissions
        .where((item) => !item.occurredAt.isBefore(thisMonthStart))
        .toList();
    final lastMonth = submissions
        .where(
          (item) =>
              !item.occurredAt.isBefore(lastMonthStart) &&
              item.occurredAt.isBefore(thisMonthStart),
        )
        .toList();

    int count(Iterable<Submission> items, SubmissionType type) =>
        items.where((item) => item.type == type).length;

    double delta(int current, int previous) {
      if (previous == 0) {
        return current > 0 ? 1 : 0;
      }
      return (current - previous) / previous;
    }

    final complaints = count(thisMonth, SubmissionType.complaint);
    final feedbacks = count(thisMonth, SubmissionType.feedback);
    final compliments = count(thisMonth, SubmissionType.compliment);
    final total = complaints + feedbacks + compliments;

    final previousComplaints = count(lastMonth, SubmissionType.complaint);
    final previousFeedbacks = count(lastMonth, SubmissionType.feedback);
    final previousCompliments = count(lastMonth, SubmissionType.compliment);
    final previousTotal =
        previousComplaints + previousFeedbacks + previousCompliments;

    return DashboardStats(
      complaints: complaints,
      feedbacks: feedbacks,
      compliments: compliments,
      complaintDelta: delta(complaints, previousComplaints),
      feedbackDelta: delta(feedbacks, previousFeedbacks),
      complimentDelta: delta(compliments, previousCompliments),
      totalDelta: delta(total, previousTotal),
    );
  }
}

String slugFromBusinessName(String businessName) {
  return businessName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

String uniqueLinkForSlug(String slug) {
  return 'https://harlequi.${slug.isEmpty ? 'business' : slug}';
}
