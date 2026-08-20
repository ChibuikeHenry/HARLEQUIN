import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text.dart';
import '../../core/constants/breakpoints.dart';
import '../../core/widgets/ui.dart';
import '../../data/models/models.dart';
import '../../viewmodels/session_viewmodel.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(MediaQuery.sizeOf(context).width);
    final session = context.watch<SessionViewModel>();
    final business = session.business;

    if (compact) {
      return Scaffold(
        backgroundColor: AppColors.page,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
          title: const Text(
            AppStrings.brand,
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        drawer: Drawer(
          child: SideNav(
            business: business,
            selected: GoRouterState.of(context).uri.path,
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.page,
      body: Row(
        children: [
          SideNav(
            business: business,
            selected: GoRouterState.of(context).uri.path,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class SideNav extends StatelessWidget {
  const SideNav({super.key, required this.selected, this.business});

  final String selected;
  final Business? business;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.brand,
                  style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppStrings.tagline,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (business != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    BusinessAvatar(business: business!, radius: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        business!.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _item(context, AppRoutes.dashboard, Icons.home_outlined, 'Dashboard'),
                _item(context, AppRoutes.complaints, Icons.warning_amber_rounded, 'Complaints'),
                _item(context, AppRoutes.feedback, Icons.chat_bubble_outline, 'Feedback'),
                _item(context, AppRoutes.compliments, Icons.favorite_border, 'Compliments'),
                _item(context, AppRoutes.customers, Icons.people_outline, 'Customers'),
                _item(context, AppRoutes.submissions, Icons.description_outlined, 'Submissions'),
                _item(context, AppRoutes.qrCodes, Icons.qr_code_2, 'QR Codes'),
                _item(context, AppRoutes.uniqueLink, Icons.link, 'Unique Link'),
                _item(context, AppRoutes.reports, Icons.insert_chart_outlined, 'Reports'),
                _item(context, AppRoutes.profile, Icons.person_outline, 'Business Profile'),
                _item(context, AppRoutes.settings, Icons.settings_outlined, 'Settings'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.helpBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.headset_mic_outlined, color: AppColors.navy, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help?',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Visit our help center or contact support.',
                          style: TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.navy),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String path, IconData icon, String label) {
    final active = selected == path;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () {
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }
            context.go(path);
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active ? AppColors.white : AppColors.text,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? AppColors.white : AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InnerPage extends StatelessWidget {
  const InnerPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.breadcrumb,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final Widget? breadcrumb;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();

    return ColoredBox(
      color: AppColors.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
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
                      Text(title, style: AppText.title),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      if (breadcrumb != null) ...[
                        const SizedBox(height: 10),
                        breadcrumb!,
                      ],
                    ],
                  ),
                ),
                trailing ??
                    (session.business == null
                        ? const SizedBox.shrink()
                        : BusinessBadge(business: session.business!)),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
