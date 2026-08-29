import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.size = 40,
    this.showWordmark = false,
    this.foregroundColor,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final Color? foregroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final wordmarkColor = foregroundColor ?? AppColors.onSurface;
    final mark = _LogoMark(size: size);

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: wordmarkColor,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryHover, AppColors.primaryPressed],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: AppColors.onPrimary,
        size: size * 0.52,
      ),
    );
  }
}
