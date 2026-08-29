import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'OR CONTINUE WITH'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceSubtle,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
