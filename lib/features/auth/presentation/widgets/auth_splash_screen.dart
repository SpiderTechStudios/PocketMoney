import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/auth_logo.dart';

class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuthLogo(size: 56, showWordmark: true),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Loading ${AppConstants.appName}',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
