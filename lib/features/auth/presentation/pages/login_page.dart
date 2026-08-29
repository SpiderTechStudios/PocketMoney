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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authActions = const AuthActions()});

  final AuthActions authActions;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool get _busy => _isLoading || _isGoogleLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_busy) return;
    setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await widget.authActions.onLogin(
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

  Future<void> _onGoogleLogin() async {
    if (_busy) return;
    setState(() => _isGoogleLoading = true);
    try {
      await widget.authActions.onGoogleLogin();
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
                title: 'Welcome back',
                subtitle: 'Sign in to continue to PocketMoney.',
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !_busy,
                validator: Validators.email,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                focusNode: _passwordFocus,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enabled: !_busy,
                validator: (value) =>
                    Validators.requiredField(value, 'Password'),
                onFieldSubmitted: (_) => _onLogin(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AuthTextLink(
                  label: 'Forgot password?',
                  enabled: !_busy,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Log in',
                isLoading: _isLoading,
                isDisabled: _isGoogleLoading,
                onPressed: _onLogin,
              ),
              const SizedBox(height: AppSpacing.xl),
              const AuthDivider(),
              const SizedBox(height: AppSpacing.xl),
              GoogleSignInButton(
                isLoading: _isGoogleLoading,
                isDisabled: _isLoading,
                onPressed: _onGoogleLogin,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AuthFooter(
                prompt: "Don't have an account? ",
                actionLabel: 'Sign Up',
                onAction: () {
                  if (_busy) return;
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.register);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
