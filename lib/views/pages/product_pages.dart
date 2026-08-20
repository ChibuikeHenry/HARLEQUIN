import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/ui.dart';
import '../../core/widgets/view_model_builder.dart';
import '../../data/models/models.dart';
import '../../data/repositories/app_repository.dart';
import '../../viewmodels/app_viewmodels.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../app/routes.dart';
import '../dashboard/dashboard_view.dart';
import '../shell/app_shell.dart';

class QrCodesView extends StatelessWidget {
  const QrCodesView({super.key});

  @override
  Widget build(BuildContext context) {
    final link = context.watch<SessionViewModel>().business?.uniqueLink ??
        'https://harlequin.app';

    return ViewModelBuilder<QrCodesViewModel>(
      create: () => QrCodesViewModel(link),
      builder: (context, vm) {
        return InnerPage(
          title: 'QR Codes',
          subtitle:
              'Customers can scan this QR code to share their feedback, complaints or compliments.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 900;
              final qrCard = AppCard(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your QR Code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: vm.link,
                        size: 240,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    HqButton(
                      label: 'Download QR Code',
                      icon: const Icon(Icons.download, size: 18),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR code download started.')),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    HqButton(
                      label: 'Print QR Code',
                      outlined: true,
                      foreground: AppColors.navy,
                      icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.navy),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opening print dialog.')),
                        );
                      },
                    ),
                  ],
                ),
              );

              final howCard = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How it works',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    const _HowStep('Customers can scan the QR code using their phone camera'),
                    const _HowStep('They will be taken to your feedback page'),
                    const _HowStep('They can submit a complaint, feedback or compliment'),
                    const _HowStep('You will receive and manage their submissions'),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.navy),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TIP',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Display your QR code at the cashier, on receipts, packaging or tables for more feedback.',
                                  style: TextStyle(fontSize: 13, color: AppColors.text),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (stacked) {
                return Column(children: [qrCard, const SizedBox(height: 16), howCard]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: qrCard),
                  const SizedBox(width: 16),
                  Expanded(child: howCard),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _HowStep extends StatelessWidget {
  const _HowStep(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.muted, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

class UniqueLinkView extends StatelessWidget {
  const UniqueLinkView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionViewModel>();
    final business = session.business!;
    final current = business.uniqueLink;

    return ViewModelBuilder<UniqueLinkViewModel>(
      create: () => UniqueLinkViewModel(
        context.read<AppRepository>(),
        business.id,
        current,
      ),
      builder: (context, vm) {
        return InnerPage(
          title: 'Unique Link',
          subtitle: 'Share this unique link with your customers to collect feedback.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 900;
              final linkCard = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Unique Link',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.linkBox,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(vm.link, style: const TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: HqButton(
                            label: vm.copied ? 'Copied' : 'Copy Link',
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(text: vm.link));
                              vm.markCopied();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HqButton(
                            label: 'Open Link',
                            outlined: true,
                            foreground: AppColors.navy,
                            onPressed: () async {
                              final uri = Uri.tryParse(vm.link);
                              if (uri != null) {
                                await launchUrl(uri);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final shareCard = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share your link',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Share the link through your preferred channels.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ShareTile(
                          color: const Color(0xFF1877F2),
                          icon: Icons.facebook,
                          label: 'Facebook',
                          onTap: () => _share(vm.link, 'facebook'),
                        ),
                        _ShareTile(
                          color: AppColors.text,
                          icon: Icons.close,
                          label: 'X (Twitter)',
                          onTap: () => _share(vm.link, 'x'),
                        ),
                        _ShareTile(
                          color: const Color(0xFF25D366),
                          icon: Icons.chat,
                          label: 'Whatsapp',
                          onTap: () => _share(vm.link, 'whatsapp'),
                        ),
                        _ShareTile(
                          color: AppColors.navy,
                          icon: Icons.mail_outline,
                          label: 'Email',
                          onTap: () => _share(vm.link, 'email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 180,
                      child: HqButton(
                        label: 'More Options',
                        outlined: true,
                        foreground: AppColors.navy,
                        icon: const Icon(Icons.ios_share, size: 16, color: AppColors.navy),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: vm.link));
                        },
                      ),
                    ),
                  ],
                ),
              );

              final customize = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize Link (optional)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    HqTextField(
                      hint: 'https://harlequi.your-business',
                      radius: 10,
                      controller: vm.controller,
                      onChanged: vm.updateDraft,
                      suffix: const Icon(Icons.link, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      child: HqButton(
                        label: vm.saved ? 'Saved' : 'Save Link',
                        busy: vm.isBusy,
                        onPressed: () async {
                          final saved = await vm.save();
                          if (saved != null && context.mounted) {
                            final current = context.read<SessionViewModel>().business;
                            if (current != null) {
                              context.read<SessionViewModel>().updateBusiness(
                                    current.copyWith(uniqueLink: saved),
                                  );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );

              if (stacked) {
                return Column(
                  children: [
                    linkCard,
                    const SizedBox(height: 16),
                    shareCard,
                    const SizedBox(height: 16),
                    customize,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: linkCard),
                      const SizedBox(width: 16),
                      Expanded(child: shareCard),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: constraints.maxWidth / 2 - 8, child: customize),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _share(String link, String channel) async {
    final encoded = Uri.encodeComponent(link);
    final uri = switch (channel) {
      'facebook' => Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encoded'),
      'x' => Uri.parse('https://twitter.com/intent/tweet?url=$encoded'),
      'whatsapp' => Uri.parse('https://wa.me/?text=$encoded'),
      _ => Uri.parse('mailto:?subject=HARLEQUIN feedback&body=$encoded'),
    };
    await launchUrl(uri);
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class BusinessProfileView extends StatelessWidget {
  const BusinessProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final business = context.watch<SessionViewModel>().business;
    if (business == null) {
      return const SizedBox.shrink();
    }

    return ViewModelBuilder<ProfileViewModel>(
      create: () => ProfileViewModel(context.read<AppRepository>(), business),
      builder: (context, vm) {
        return InnerPage(
          title: 'Profile',
          subtitle: 'Manage your business profile and preferences',
          breadcrumb: const Row(
            children: [
              Text('Home', style: TextStyle(color: AppColors.status, fontSize: 12)),
              Text('  >  ', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              Text('Business Profile', style: TextStyle(fontSize: 12)),
            ],
          ),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Information',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 640;
                        final avatar = const CircleAvatar(
                          radius: 56,
                          backgroundColor: Color(0xFFD9D9D9),
                        );
                        final fields = Column(
                          children: [
                            HqTextField(
                              label: 'Business Name',
                              hint: '',
                              onChanged: vm.updateName,
                            ),
                            const SizedBox(height: 12),
                            HqTextField(
                              label: 'Business Email',
                              hint: '',
                              onChanged: vm.updateEmail,
                            ),
                            const SizedBox(height: 12),
                            HqTextField(
                              label: 'Phone Number',
                              hint: '',
                              onChanged: vm.updatePhone,
                            ),
                          ],
                        );

                        if (stacked) {
                          return Column(
                            children: [
                              avatar,
                              const SizedBox(height: 20),
                              fields,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            avatar,
                            const SizedBox(width: 28),
                            Expanded(child: fields),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 160,
                      child: HqButton(
                        label: vm.saved ? 'Saved' : 'Save profile',
                        busy: vm.isBusy,
                        onPressed: () async {
                          final saved = await vm.save();
                          if (saved != null && context.mounted) {
                            context.read<SessionViewModel>().updateBusiness(saved);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 160,
                width: double.infinity,
                child: AppCard(child: SizedBox.shrink()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ListPageView extends StatelessWidget {
  const ListPageView({
    super.key,
    required this.title,
    required this.subtitle,
    this.filter,
  });

  final String title;
  final String subtitle;
  final SubmissionType? filter;

  @override
  Widget build(BuildContext context) {
    final businessId = context.read<SessionViewModel>().business!.id;

    return ViewModelBuilder<SubmissionsListViewModel>(
      create: () => SubmissionsListViewModel(
        context.read<AppRepository>(),
        businessId,
        filter: filter,
      ),
      builder: (context, vm) {
        return InnerPage(
          title: title,
          subtitle: subtitle,
          child: AppCard(
            child: vm.isBusy && vm.items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.navy),
                    ),
                  )
                : vm.items.isEmpty
                    ? EmptyState(
                        message: filter == null
                            ? 'No submissions yet.'
                            : 'No ${title.toLowerCase()} yet.',
                      )
                    : SubmissionsTable(items: vm.items),
          ),
        );
      },
    );
  }
}

class CustomersPageView extends StatelessWidget {
  const CustomersPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final businessId = context.read<SessionViewModel>().business!.id;

    return ViewModelBuilder<CustomersViewModel>(
      create: () => CustomersViewModel(context.read<AppRepository>(), businessId),
      builder: (context, vm) {
        return InnerPage(
          title: 'Customers',
          subtitle: 'People who have submitted feedback to this business.',
          child: AppCard(
            child: vm.isBusy && vm.customers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.navy),
                    ),
                  )
                : vm.customers.isEmpty
                    ? const EmptyState(
                        message:
                            'No customers yet. They will appear here after submitting feedback.',
                      )
                    : Column(
                        children: [
                          for (final customer in vm.customers)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.helpBg,
                                child: Text(customer.name[0]),
                              ),
                              title: Text(customer.name),
                              subtitle: Text(customer.lastSubject),
                            ),
                        ],
                      ),
          ),
        );
      },
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const InnerPage(
      title: 'Reports',
      subtitle: 'Trends across complaints, feedback and compliments.',
      child: SizedBox(
        height: 360,
        child: AppCard(
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Insights will appear here as submissions grow.',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return InnerPage(
      title: 'Settings',
      subtitle: 'Account and workspace preferences.',
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are signed in on the HARLEQUIN web workspace.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: HqButton(
                label: 'Sign out',
                background: AppColors.loginGray,
                onPressed: () async {
                  await context.read<SessionViewModel>().signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.signIn);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
