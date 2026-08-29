import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controllers/auth_actions.dart';
import '../utils/show_auth_error.dart';
import '../../domain/auth_failure.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_logo.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordSuccessPage extends StatefulWidget {
  const ForgotPasswordSuccessPage({
    super.key,
    required this.email,
    this.authActions = const AuthActions(),
  });

  final String email;
  final AuthActions authActions;

  @override
  State<ForgotPasswordSuccessPage> createState() =>
      _ForgotPasswordSuccessPageState();
}

class _ForgotPasswordSuccessPageState extends State<ForgotPasswordSuccessPage> {
  bool _isResending = false;

  Future<void> _onResend() async {
    if (_isResending || widget.email.isEmpty) return;
    setState(() => _isResending = true);
    try {
      await widget.authActions.onResendResetEmail(email: widget.email);
      if (!mounted) return;
      showAuthMessage(context, 'Reset email sent again.');
    } on AuthCancelledException {
      return;
    } catch (error) {
      if (!mounted) return;
      showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _backToLogin() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emailLabel = widget.email.isEmpty ? 'your email' : widget.email;

    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!Breakpoints.isDesktop(context)) ...[
            const AuthLogo(showWordmark: true),
            const SizedBox(height: AppSpacing.xxl),
          ],
          const Center(child: _SuccessMark()),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text.rich(
            TextSpan(
              text: 'We sent a password reset link to ',
              children: [
                TextSpan(
                  text: emailLabel,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: '. Follow the link to choose a new password.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(label: 'Back to Login', onPressed: _backToLogin),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text("Didn't receive the email? ", style: textTheme.bodyMedium),
              if (_isResending)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                AuthTextLink(
                  label: 'Resend',
                  onPressed: widget.email.isEmpty ? null : _onResend,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.successMuted,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.mark_email_read_rounded,
        size: 40,
        color: AppColors.success,
      ),
    );
  }
}
