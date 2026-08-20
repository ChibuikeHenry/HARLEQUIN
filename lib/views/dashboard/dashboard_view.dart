import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text.dart';
import '../../core/constants/breakpoints.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/ui.dart';
import '../../core/widgets/view_model_builder.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_repository.dart';
import '../../viewmodels/app_viewmodels.dart';
import '../../viewmodels/session_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId = context.read<SessionViewModel>().business!.id;

    return ViewModelBuilder<DashboardViewModel>(
      create: () => DashboardViewModel(context.read<AppRepository>(), businessId),
      builder: (context, vm) {
        final session = context.watch<SessionViewModel>();
        final user = session.user;
        final compact = Breakpoints.isCompact(MediaQuery.sizeOf(context).width);
        final stats = vm.stats;

        return ColoredBox(
          color: AppColors.page,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: AppText.title.copyWith(color: AppColors.navy),
                              children: [
                                const TextSpan(text: 'Welcome Back, '),
                                TextSpan(text: user?.firstName ?? 'there'),
                                const TextSpan(text: '! '),
                                const TextSpan(text: '\u{1F44B}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Here's what's happening with your customer feedbacks.",
                            style: TextStyle(color: AppColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (user != null) _UserChip(user: user),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: _DateRangeChip(label: currentMonthRangeLabel()),
                ),
                const SizedBox(height: 16),
                if (vm.isBusy && stats == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.navy),
                    ),
                  )
                else if (stats != null) ...[
                  _StatsRow(stats: stats, compact: compact),
                  const SizedBox(height: 16),
                  _DashboardBody(viewModel: vm, compact: compact),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFD9D9D9),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                user.role,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  const _DateRangeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.compact});

  final DashboardStats stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        label: 'Complaints',
        value: '${stats.complaints}',
        delta: stats.complaintDelta,
        icon: Icons.warning_amber_rounded,
        iconBg: AppColors.complaintBg,
        iconColor: AppColors.complaint,
      ),
      _StatCard(
        label: 'Feedbacks',
        value: '${stats.feedbacks}',
        delta: stats.feedbackDelta,
        icon: Icons.chat_bubble_outline,
        iconBg: AppColors.feedbackBg,
        iconColor: AppColors.feedback,
      ),
      _StatCard(
        label: 'Compliments',
        value: '${stats.compliments}',
        delta: stats.complimentDelta,
        icon: Icons.favorite,
        iconBg: AppColors.complimentBg,
        iconColor: AppColors.compliment,
      ),
      _StatCard(
        label: 'Total Submissions',
        value: '${stats.total}',
        delta: stats.totalDelta,
        icon: Icons.groups_outlined,
        iconBg: AppColors.submissionBg,
        iconColor: AppColors.submission,
      ),
    ];

    if (compact) {
      return Column(
        children: [
          for (final card in cards) ...[card, const SizedBox(height: 12)],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i != cards.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String value;
  final double delta;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final up = delta >= 0;
    final percent = '${(delta.abs() * 100).round()}%';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      up ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: up ? AppColors.up : AppColors.down,
                    ),
                    Text(
                      percent,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: up ? AppColors.up : AppColors.down,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'vs. previous month',
                  style: TextStyle(fontSize: 10, color: AppColors.hint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.viewModel, required this.compact});

  final DashboardViewModel viewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final table = AppCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              _Tab(
                label: 'All (${viewModel.submissions.length})',
                selected: viewModel.tab == DashboardTab.all,
                onTap: () => viewModel.selectTab(DashboardTab.all),
              ),
              _Tab(
                label:
                    'Complaints (${viewModel.submissions.where((s) => s.type == SubmissionType.complaint).length})',
                selected: viewModel.tab == DashboardTab.complaints,
                onTap: () => viewModel.selectTab(DashboardTab.complaints),
              ),
              _Tab(
                label:
                    'Feedbacks (${viewModel.submissions.where((s) => s.type == SubmissionType.feedback).length})',
                selected: viewModel.tab == DashboardTab.feedbacks,
                onTap: () => viewModel.selectTab(DashboardTab.feedbacks),
              ),
              _Tab(
                label:
                    'Compliments (${viewModel.submissions.where((s) => s.type == SubmissionType.compliment).length})',
                selected: viewModel.tab == DashboardTab.compliments,
                onTap: () => viewModel.selectTab(DashboardTab.compliments),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('Newest first', style: TextStyle(fontSize: 12)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SubmissionsTable(items: viewModel.visible),
        ],
      ),
    );

    final side = _InsightsColumn(submissions: viewModel.submissions);

    if (compact) {
      return Column(
        children: [
          table,
          if (viewModel.submissions.isNotEmpty) ...[
            const SizedBox(height: 12),
            side,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: table),
        if (viewModel.submissions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Expanded(flex: 3, child: side),
        ],
      ],
    );
  }
}

class _InsightsColumn extends StatelessWidget {
  const _InsightsColumn({required this.submissions});

  final List<Submission> submissions;

  @override
  Widget build(BuildContext context) {
    final complaints = submissions
        .where((item) => item.type == SubmissionType.complaint)
        .take(5)
        .toList();
    final channels = <String, int>{};
    for (final item in submissions) {
      channels[item.channel] = (channels[item.channel] ?? 0) + 1;
    }

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Improvement Areas',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (complaints.isEmpty)
                const Text(
                  'No complaints recorded yet.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                )
              else
                for (final item in complaints)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• ${item.subject}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submissions by Channel',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (channels.isEmpty)
                const Text(
                  'No channel data yet.',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                )
              else
                for (final entry in channels.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.navy : AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: selected ? 28 : 0,
              color: AppColors.navy,
            ),
          ],
        ),
      ),
    );
  }
}

class SubmissionsTable extends StatelessWidget {
  const SubmissionsTable({super.key, required this.items});

  final List<Submission> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        message: 'No submissions yet. Share your QR code or unique link to start receiving feedback.',
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _Head('Type', flex: 3),
              _Head('Customer', flex: 3),
              _Head('Date & Time', flex: 3),
              _Head('Subject', flex: 3),
              _Head('Status', flex: 2),
              SizedBox(width: 28),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final item in items) _RowItem(item: item),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  const _Head(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.item});

  final Submission item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.type) {
      SubmissionType.complaint => AppColors.complaint,
      SubmissionType.feedback => AppColors.feedback,
      SubmissionType.compliment => AppColors.compliment,
    };
    final icon = switch (item.type) {
      SubmissionType.complaint => Icons.warning_amber_rounded,
      SubmissionType.feedback => Icons.chat_bubble_outline,
      SubmissionType.compliment => Icons.favorite,
    };
    final date =
        '${_month(item.occurredAt.month)} ${item.occurredAt.day.toString().padLeft(2, '0')}, ${item.occurredAt.year}';
    final time =
        '${item.occurredAt.hour.toString().padLeft(2, '0')}:${item.occurredAt.minute.toString().padLeft(2, '0')} AM';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  item.typeLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(item.customerName, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '$date\n$time',
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(item.subject, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: StatusChip(label: submissionStatusLabel(item.status)),
          ),
          const SizedBox(
            width: 28,
            child: Icon(Icons.more_horiz, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  String _month(int month) {
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
}
