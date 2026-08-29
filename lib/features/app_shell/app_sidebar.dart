import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/presentation/widgets/auth_logo.dart';
import 'app_nav.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.expanded,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
    required this.onToggle,
  });

  final bool expanded;
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onLogout;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: expanded ? 248 : 80,
      color: AppColors.brandingBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 12, 16),
              child: Row(
                children: [
                  if (expanded)
                    const Expanded(
                      child: AuthLogo(
                        size: 36,
                        showWordmark: true,
                        foregroundColor: AppColors.onBranding,
                      ),
                    )
                  else
                    const AuthLogo(size: 36),
                  if (expanded)
                    IconButton(
                      tooltip: 'Collapse menu',
                      onPressed: onToggle,
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: AppColors.onBrandingMuted,
                    ),
                ],
              ),
            ),
            if (!expanded)
              IconButton(
                tooltip: 'Expand menu',
                onPressed: onToggle,
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.onBrandingMuted,
              ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in appNavItems)
              _NavTile(
                item: item,
                expanded: expanded,
                selected: item.section == selected,
                onTap: () => onSelect(item.section),
              ),
            const Spacer(),
            _NavTile(
              item: const AppNavItem(
                section: AppSection.settings,
                label: 'Logout',
                icon: Icons.logout_rounded,
              ),
              expanded: expanded,
              selected: false,
              onTap: onLogout,
              danger: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class AppDrawerMenu extends StatelessWidget {
  const AppDrawerMenu({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onLogout,
  });

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.brandingBackground,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AuthLogo(
                  size: 36,
                  showWordmark: true,
                  foregroundColor: AppColors.onBranding,
                ),
              ),
            ),
            for (final item in appNavItems)
              _NavTile(
                item: item,
                expanded: true,
                selected: item.section == selected,
                onTap: () => onSelect(item.section),
              ),
            const Spacer(),
            _NavTile(
              item: const AppNavItem(
                section: AppSection.settings,
                label: 'Logout',
                icon: Icons.logout_rounded,
              ),
              expanded: true,
              selected: false,
              onTap: onLogout,
              danger: true,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.expanded,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  final AppNavItem item;
  final bool expanded;
  final bool selected;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFFECACA)
        : selected
        ? AppColors.onBranding
        : AppColors.onBrandingMuted;
    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected
            ? AppColors.onBranding.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                if (expanded) const SizedBox(width: 12),
                Icon(item.icon, color: color, size: 22),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: color,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (expanded) return tile;
    return Tooltip(message: item.label, child: tile);
  }
}
