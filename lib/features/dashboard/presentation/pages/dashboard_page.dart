import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/controllers/auth_actions.dart';
import '../../../auth/presentation/utils/show_auth_error.dart';
import '../../../auth/presentation/widgets/auth_logo.dart';
import '../../../auth/presentation/widgets/primary_button.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.authActions = const AuthActions()});

  final AuthActions authActions;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoggingOut = false;

  Future<void> _onLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await widget.authActions.onLogout();
    } catch (error) {
      if (!mounted) return;
      showAuthError(context, error);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: StreamBuilder<AppUser?>(
          stream: widget.authActions.userChanges,
          initialData: widget.authActions.currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data ?? widget.authActions.currentUser;
            final name = user?.welcomeName ?? 'there';
            final email = user?.email ?? '';

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthLogo(showWordmark: true),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'Welcome, $name',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            email.isEmpty
                                ? 'You are signed in to ${AppConstants.appName}.'
                                : email,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          PrimaryButton(
                            label: 'Log out',
                            isLoading: _isLoggingOut,
                            onPressed: _onLogout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
