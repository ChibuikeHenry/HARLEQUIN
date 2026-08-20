enum SubmissionType { complaint, feedback, compliment }

enum SubmissionStatus { inProgress, resolved, open }

class Submission {
  const Submission({
    required this.id,
    required this.type,
    required this.customerName,
    required this.occurredAt,
    required this.subject,
    required this.status,
    this.channel = 'web',
  });

  final String id;
  final SubmissionType type;
  final String customerName;
  final DateTime occurredAt;
  final String subject;
  final SubmissionStatus status;
  final String channel;

  String get typeLabel => switch (type) {
        SubmissionType.complaint => 'Complaints',
        SubmissionType.feedback => 'Feedbacks',
        SubmissionType.compliment => 'Compliments',
      };

  Submission copyWith({
    String? id,
    SubmissionType? type,
    String? customerName,
    DateTime? occurredAt,
    String? subject,
    SubmissionStatus? status,
    String? channel,
  }) {
    return Submission(
      id: id ?? this.id,
      type: type ?? this.type,
      customerName: customerName ?? this.customerName,
      occurredAt: occurredAt ?? this.occurredAt,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      channel: channel ?? this.channel,
    );
  }
}

class UserAccount {
  const UserAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.businessId,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String businessId;

  String get fullName => '$firstName $lastName';
}

class Business {
  const Business({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.uniqueLink,
    required this.slug,
    this.initial = 'K',
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String uniqueLink;
  final String slug;
  final String initial;

  Business copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? uniqueLink,
    String? slug,
    String? initial,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      uniqueLink: uniqueLink ?? this.uniqueLink,
      slug: slug ?? this.slug,
      initial: initial ?? this.initial,
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.complaints,
    required this.feedbacks,
    required this.compliments,
    required this.complaintDelta,
    required this.feedbackDelta,
    required this.complimentDelta,
    required this.totalDelta,
  });

  final int complaints;
  final int feedbacks;
  final int compliments;
  final double complaintDelta;
  final double feedbackDelta;
  final double complimentDelta;
  final double totalDelta;

  int get total => complaints + feedbacks + compliments;
}

class Customer {
  const Customer({required this.name, required this.lastSubject});

  final String name;
  final String lastSubject;
}
