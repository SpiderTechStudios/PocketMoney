import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'auth_logo.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBack,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final breakpoint = Breakpoints.fromWidth(constraints.maxWidth);

          return switch (breakpoint) {
            Breakpoint.desktop => _DesktopShell(
              showBackButton: showBackButton,
              onBack: onBack,
              child: child,
            ),
            Breakpoint.tablet => _FormShell(
              showBackButton: showBackButton,
              onBack: onBack,
              horizontalPadding: AppSpacing.xxl,
              useCard: constraints.maxHeight >= 760,
              child: child,
            ),
            Breakpoint.mobile => _FormShell(
              showBackButton: showBackButton,
              onBack: onBack,
              horizontalPadding: AppSpacing.xl,
              useCard: false,
              child: child,
            ),
          };
        },
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.child,
    required this.showBackButton,
    this.onBack,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 5, child: AuthBrandingPanel()),
        Expanded(
          flex: 4,
          child: ColoredBox(
            color: AppColors.surface,
            child: _FormShell(
              showBackButton: showBackButton,
              onBack: onBack,
              horizontalPadding: AppSpacing.xxxl,
              useCard: false,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({
    required this.child,
    required this.showBackButton,
    required this.horizontalPadding,
    required this.useCard,
    this.onBack,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double horizontalPadding;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final verticalPadding = Breakpoints.isCompactHeight(context)
        ? AppSpacing.md
        : AppSpacing.xl;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBackButton)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding - 8,
                  AppSpacing.sm,
                  horizontalPadding,
                  0,
                ),
                child: _AuthBackButton(onPressed: onBack),
              ),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, viewport) {
                final minHeight = (viewport.maxHeight - (verticalPadding * 2))
                    .clamp(0.0, double.infinity);

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.formMaxWidth,
                        ),
                        child: useCard ? _AuthCard(child: child) : child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        child: child,
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back_rounded),
      color: AppColors.onSurface,
    );
  }
}

class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandingBackground,
            Color(0xFF0B4F4A),
            AppColors.brandingBackgroundEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          const _BrandingAtmosphere(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxxl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (AppSpacing.xxl * 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AuthLogo(
                          size: 44,
                          showWordmark: true,
                          foregroundColor: AppColors.onBranding,
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                AppConstants.appTagline,
                                style: textTheme.headlineLarge?.copyWith(
                                  color: AppColors.onBranding,
                                  fontSize: 40,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'A calm, focused way to track spending, plan ahead, and stay in control of every dollar.',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onBrandingMuted,
                                  fontSize: 17,
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              const _BrandingFeature(
                                icon: Icons.insights_rounded,
                                title: 'Clear overview',
                                subtitle: 'See where your money actually goes.',
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const _BrandingFeature(
                                icon: Icons.flag_rounded,
                                title: 'Goals that stick',
                                subtitle: 'Plan with intention, not guesswork.',
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const _BrandingFeature(
                                icon: Icons.lock_outline_rounded,
                                title: 'Private by design',
                                subtitle: 'Your finances stay yours.',
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
                        ),
                        Text(
                          'Built for people who want less noise and more clarity.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onBrandingMuted.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandingAtmosphere extends StatelessWidget {
  const _BrandingAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              size: 280,
              color: AppColors.primaryHover.withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -40,
            child: _GlowOrb(
              size: 180,
              color: AppColors.accent.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BrandingFeature extends StatelessWidget {
  const _BrandingFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.onBranding.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: AppColors.onBrandingMuted, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.onBranding,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBrandingMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
