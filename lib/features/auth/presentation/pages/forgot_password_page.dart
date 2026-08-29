import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../controllers/auth_actions.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.authActions = const AuthActions()});

  final AuthActions authActions;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _onSendResetLink() async {
    if (_isLoading) return;
    setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      await widget.authActions.onForgotPassword(email: email);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamed(AppRoutes.forgotPasswordSuccess, arguments: email);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBackButton: true,
      onBack: _isLoading ? null : () => Navigator.of(context).maybePop(),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'Forgot your password?',
                subtitle: "Enter your email address and we'll send you a link to reset your password.",
                showLogo: !Breakpoints.isDesktop(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                focusNode: _emailFocus,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enabled: !_isLoading,
                validator: Validators.email,
                onFieldSubmitted: (_) => _onSendResetLink(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Send reset link',
                isLoading: _isLoading,
                onPressed: _onSendResetLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
