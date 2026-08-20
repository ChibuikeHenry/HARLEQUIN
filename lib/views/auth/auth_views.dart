import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text.dart';
import '../../core/widgets/ui.dart';
import '../../core/widgets/view_model_builder.dart';
import '../../data/repositories/app_repository.dart';
import '../../viewmodels/session_viewmodel.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignInViewModel>(
      create: () => SignInViewModel(context.read<SessionViewModel>()),
      builder: (context, vm) {
        return Scaffold(
          backgroundColor: AppColors.page,
          body: Stack(
            children: [
              const AuthBlobs(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.brand,
                          style: AppText.title.copyWith(color: AppColors.navy),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppStrings.tagline,
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                        const SizedBox(height: 36),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Welcome Back!', style: AppText.title),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Sign in to your business account',
                            style: TextStyle(fontSize: 13, color: AppColors.muted),
                          ),
                        ),
                        const SizedBox(height: 22),
                        HqTextField(
                          hint: 'Business Email',
                          keyboardType: TextInputType.emailAddress,
                          controller: vm.emailController,
                          errorText: vm.emailError,
                          onChanged: (_) {
                            vm.emailError = null;
                            vm.notifyListeners();
                          },
                        ),
                        const SizedBox(height: 14),
                        HqTextField(
                          hint: 'Password',
                          controller: vm.passwordController,
                          obscureText: vm.obscurePassword,
                          errorText: vm.passwordError,
                          onChanged: (_) {
                            vm.passwordError = null;
                            vm.notifyListeners();
                          },
                          suffix: IconButton(
                            onPressed: vm.toggleObscure,
                            icon: Icon(
                              vm.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.muted,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        HqButton(
                          label: 'Log in',
                          background: AppColors.loginGray,
                          busy: vm.isBusy,
                          onPressed: () async {
                            if (await vm.submit() && context.mounted) {
                              context.go(AppRoutes.dashboard);
                            }
                          },
                        ),
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.complaint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.forgotPassword),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go(AppRoutes.signUp),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF2F6FED),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: vm.isBusy
                                ? null
                                : () async {
                                    if (await vm.continueWithGoogle() &&
                                        context.mounted) {
                                      context.go(AppRoutes.dashboard);
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              side: const BorderSide(color: AppColors.line),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 8),
                                _GoogleMark(),
                                Expanded(
                                  child: Text(
                                    'Continue with Google',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 28),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SignUpViewModel>(
      create: () => SignUpViewModel(context.read<SessionViewModel>()),
      builder: (context, vm) {
        final wide = MediaQuery.sizeOf(context).width >= 960;
        final session = context.watch<SessionViewModel>();
        final canSubmit = session.initialized && !vm.isBusy;

        return Scaffold(
          backgroundColor: AppColors.page,
          body: Stack(
            children: [
              const AuthBlobs(),
              Row(
                children: [
                  if (wide) const _PitchPanel(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: AppCard(
                            radius: 20,
                            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    AppStrings.brand,
                                    style: TextStyle(
                                      color: AppColors.navy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    AppStrings.tagline,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Create your business account',
                                  style: AppText.title,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Sign up and get started on receiving feedbacks.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                HqTextField(
                                  label: 'First Name',
                                  hint: 'Enter your first name',
                                  radius: 24,
                                  controller: vm.firstNameController,
                                  errorText: vm.firstNameError,
                                  onChanged: (_) => vm.clearFirstNameError(),
                                ),
                                const SizedBox(height: 12),
                                HqTextField(
                                  label: 'Last Name',
                                  hint: 'Enter your last name',
                                  radius: 24,
                                  controller: vm.lastNameController,
                                  errorText: vm.lastNameError,
                                  onChanged: (_) => vm.clearLastNameError(),
                                ),
                                const SizedBox(height: 12),
                                HqTextField(
                                  label: 'Business Name',
                                  hint: 'Enter your business name',
                                  radius: 24,
                                  controller: vm.businessNameController,
                                  errorText: vm.businessNameError,
                                  onChanged: (_) => vm.clearBusinessNameError(),
                                ),
                                const SizedBox(height: 12),
                                HqTextField(
                                  label: 'Business Email',
                                  hint: 'name@yourbusiness.com',
                                  radius: 24,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: vm.emailController,
                                  errorText: vm.emailError,
                                  onChanged: (_) => vm.clearEmailError(),
                                ),
                                const SizedBox(height: 12),
                                HqTextField(
                                  label: 'Password',
                                  hint: 'Create a strong password',
                                  radius: 24,
                                  obscureText: vm.obscurePassword,
                                  controller: vm.passwordController,
                                  errorText: vm.passwordError,
                                  onChanged: (_) => vm.clearPasswordError(),
                                  suffix: IconButton(
                                    onPressed: vm.toggleObscurePassword,
                                    icon: Icon(
                                      vm.obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.muted,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                HqTextField(
                                  label: 'Confirm Password',
                                  hint: 'Enter password again',
                                  radius: 24,
                                  obscureText: vm.obscureConfirmPassword,
                                  controller: vm.confirmPasswordController,
                                  errorText: vm.confirmError,
                                  onChanged: (_) => vm.clearConfirmError(),
                                  suffix: IconButton(
                                    onPressed: vm.toggleObscureConfirmPassword,
                                    icon: Icon(
                                      vm.obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.muted,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                HqButton(
                                  label: session.initialized
                                      ? 'Create Account'
                                      : 'Loading...',
                                  busy: vm.isBusy,
                                  onPressed: canSubmit
                                      ? () async {
                                          if (await vm.submit() &&
                                              context.mounted) {
                                            context.go(AppRoutes.dashboard);
                                          }
                                        }
                                      : null,
                                ),
                                if (vm.errorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    vm.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.complaint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                const Center(
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'By signing up, you agree to our ',
                                        ),
                                        TextSpan(
                                          text: 'Terms of service',
                                          style: TextStyle(color: Color(0xFF2F6FED)),
                                        ),
                                        TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy.',
                                          style: TextStyle(color: Color(0xFF2F6FED)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Wrap(
                                    children: [
                                      const Text(
                                        'Already have an account? ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      GestureDetector(
                                        onTap: () => context.go(AppRoutes.signIn),
                                        child: const Text(
                                          'Log in',
                                          style: TextStyle(
                                            color: Color(0xFF2F6FED),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PitchPanel extends StatelessWidget {
  const _PitchPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.38,
      color: AppColors.navy,
      padding: const EdgeInsets.fromLTRB(48, 56, 40, 48),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.brand,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppStrings.tagline,
            style: TextStyle(color: Color(0xFFD7DEEE), fontSize: 12),
          ),
          Spacer(),
          Text(
            'All your complaints\nand feedback in one\nplace.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          SizedBox(height: 36),
          _PitchLine('Collect feedback or complaints from any channel.'),
          _PitchLine('Track and Assign.'),
          _PitchLine('Respond and Resolve.'),
          _PitchLine('Gain powerful insight.'),
          Spacer(),
        ],
      ),
    );
  }
}

class _PitchLine extends StatelessWidget {
  const _PitchLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppColors.white, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForgotPasswordViewModel>(
      create: () => ForgotPasswordViewModel(context.read<AuthRepository>()),
      builder: (context, vm) {
        return Scaffold(
          backgroundColor: AppColors.page,
          body: Stack(
            children: [
              const AuthBlobs(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AppCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot password?',
                          style: AppText.title,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your business email and we will send a reset link.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 20),
                        if (vm.sent)
                          const Text('Reset email sent. Check your inbox.')
                        else ...[
                          HqTextField(
                            hint: 'Business Email',
                            errorText: vm.emailError,
                            onChanged: vm.updateEmail,
                          ),
                          const SizedBox(height: 16),
                          HqButton(
                            label: 'Send reset link',
                            busy: vm.isBusy,
                            onPressed: vm.submit,
                          ),
                        ],
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signIn),
                          child: const Text('Back to sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
