import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/auth_failure.dart';
import '../controllers/auth_actions.dart';
import '../utils/show_auth_error.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.authActions = const AuthActions()});

  final AuthActions authActions;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool get _busy => _isLoading || _isGoogleLoading;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (_busy) return;
    setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await widget.authActions.onRegister(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      TextInput.finishAutofillContext();
    } on AuthCancelledException {
      return;
    } catch (error) {
      if (!mounted) return;
      showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleRegister() async {
    if (_busy) return;
    setState(() => _isGoogleLoading = true);
    try {
      await widget.authActions.onGoogleRegister();
    } on AuthCancelledException {
      return;
    } catch (error) {
      if (!mounted) return;
      showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'Create your account',
                subtitle: 'Start taking control of your money in a few steps.',
                showLogo: !Breakpoints.isDesktop(context),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthTextField(
                label: 'Full name',
                hint: 'Jane Doe',
                controller: _nameController,
                focusNode: _nameFocus,
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                autocorrect: true,
                enabled: !_busy,
                validator: Validators.fullName,
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                focusNode: _emailFocus,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !_busy,
                validator: Validators.email,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Password',
                hint: 'At least 8 characters',
                controller: _passwordController,
                focusNode: _passwordFocus,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_busy,
                validator: Validators.password,
                onChanged: (_) {
                  if (_autoValidateMode != AutovalidateMode.disabled &&
                      _confirmPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Confirm password',
                hint: 'Re-enter your password',
                controller: _confirmPasswordController,
                focusNode: _confirmFocus,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_busy,
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
                onFieldSubmitted: (_) => _onRegister(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                isDisabled: _isGoogleLoading,
                onPressed: _onRegister,
              ),
              const SizedBox(height: AppSpacing.xl),
              const AuthDivider(),
              const SizedBox(height: AppSpacing.xl),
              GoogleSignInButton(
                isLoading: _isGoogleLoading,
                isDisabled: _isLoading,
                onPressed: _onGoogleRegister,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthFooter(
                prompt: 'Already have an account? ',
                actionLabel: 'Login',
                onAction: () {
                  if (_busy) return;
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
