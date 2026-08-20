import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import '../data/models/models.dart';
import '../viewmodels/session_viewmodel.dart';
import '../views/auth/auth_views.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/pages/product_pages.dart';
import '../views/shell/app_shell.dart';
import 'routes.dart';

export 'routes.dart';

GoRouter createRouter(SessionViewModel session) {
  return GoRouter(
    initialLocation:
        session.isLoggedIn ? AppRoutes.dashboard : AppRoutes.signIn,
    refreshListenable: session,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    redirect: (context, state) {
      if (!session.initialized) {
        return null;
      }

      final loggedIn = session.isLoggedIn;
      final loggingIn = {
        AppRoutes.signIn,
        AppRoutes.signUp,
        AppRoutes.forgotPassword,
      }.contains(state.matchedLocation);

      if (!loggedIn && !loggingIn) {
        return AppRoutes.signIn;
      }
      if (loggedIn && loggingIn) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardView(),
          ),
          GoRoute(
            path: AppRoutes.complaints,
            builder: (context, state) => const ListPageView(
              title: 'Complaints',
              subtitle: 'Track and resolve customer complaints.',
              filter: SubmissionType.complaint,
            ),
          ),
          GoRoute(
            path: AppRoutes.feedback,
            builder: (context, state) => const ListPageView(
              title: 'Feedback',
              subtitle: 'Customer feedback across channels.',
              filter: SubmissionType.feedback,
            ),
          ),
          GoRoute(
            path: AppRoutes.compliments,
            builder: (context, state) => const ListPageView(
              title: 'Compliments',
              subtitle: 'Praise from your customers.',
              filter: SubmissionType.compliment,
            ),
          ),
          GoRoute(
            path: AppRoutes.customers,
            builder: (context, state) => const CustomersPageView(),
          ),
          GoRoute(
            path: AppRoutes.submissions,
            builder: (context, state) => const ListPageView(
              title: 'Submissions',
              subtitle: 'Every complaint, feedback and compliment in one place.',
            ),
          ),
          GoRoute(
            path: AppRoutes.qrCodes,
            builder: (context, state) => const QrCodesView(),
          ),
          GoRoute(
            path: AppRoutes.uniqueLink,
            builder: (context, state) => const UniqueLinkView(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            builder: (context, state) => const ReportsView(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const BusinessProfileView(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
}
