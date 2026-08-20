import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

String submissionStatusLabel(SubmissionStatus status) => switch (status) {
      SubmissionStatus.resolved => 'Resolved',
      SubmissionStatus.open => 'Open',
      SubmissionStatus.inProgress => 'In Progress',
    };

String currentMonthRangeLabel() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1, 0);
  return '${_monthName(start.month)} ${start.day}, ${start.year} - '
      '${_monthName(end.month)} ${end.day}, ${end.year}';
}

String _monthName(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return names[month - 1];
}
