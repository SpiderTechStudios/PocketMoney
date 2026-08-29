import 'package:flutter/material.dart';

enum AppSection { dashboard, record, history, reminders, settings }

class AppNavItem {
  const AppNavItem({
    required this.section,
    required this.label,
    required this.icon,
  });

  final AppSection section;
  final String label;
  final IconData icon;
}

const appNavItems = [
  AppNavItem(
    section: AppSection.dashboard,
    label: 'Dashboard',
    icon: Icons.home_rounded,
  ),
  AppNavItem(
    section: AppSection.record,
    label: 'Record',
    icon: Icons.add_circle_outline_rounded,
  ),
  AppNavItem(
    section: AppSection.history,
    label: 'History',
    icon: Icons.history_rounded,
  ),
  AppNavItem(
    section: AppSection.reminders,
    label: 'Reminders',
    icon: Icons.notifications_none_rounded,
  ),
  AppNavItem(
    section: AppSection.settings,
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
];
