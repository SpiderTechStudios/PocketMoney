import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'auth_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          const AuthLogo(showWordmark: true),
          SizedBox(
            height: Breakpoints.isCompactHeight(context)
                ? AppSpacing.xl
                : AppSpacing.xxl,
          ),
        ],
        Text(title, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
