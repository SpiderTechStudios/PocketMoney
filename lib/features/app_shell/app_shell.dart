import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/domain/models/app_user.dart';
import '../auth/presentation/controllers/auth_actions.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../money/data/user_workspace_service.dart';
import '../money/presentation/pages/history_page.dart';
import '../money/presentation/pages/record_page.dart';
import '../money/presentation/pages/reminders_page.dart';
import '../money/presentation/pages/settings_page.dart';
import '../money/presentation/widgets/feedback.dart';
import 'app_nav.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.user,
    this.authActions = const AuthActions(),
  });

  final AppUser user;
  final AuthActions authActions;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AppSection _section = AppSection.dashboard;
  bool _expanded = true;
  bool _ready = false;
  Object? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await UserWorkspaceService.instance.ensureReady(
        name: widget.user.displayName,
        email: widget.user.email,
        photoUrl: widget.user.photoUrl,
        provider: widget.user.provider ?? 'password',
      );
      if (mounted) setState(() => _ready = true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _bootstrapError = error;
          _ready = true;
        });
      }
    }
  }

  void _select(AppSection section) {
    setState(() => _section = section);
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _logout() async {
    _scaffoldKey.currentState?.closeDrawer();
    final confirmed = await confirmAction(
      context,
      title: 'Log out',
      message: 'Sign out of PocketMoney on this device?',
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await widget.authActions.onLogout();
    } catch (error) {
      if (!mounted) return;
      showAppError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final useDrawer = !Breakpoints.isDesktop(context);

    final titles = {
      AppSection.dashboard: 'Dashboard',
      AppSection.record: 'Record',
      AppSection.history: 'History',
      AppSection.reminders: 'Reminders',
      AppSection.settings: 'Settings',
    };

    final Widget body;
    if (!_ready) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_bootstrapError != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your workspace.'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _ready = false;
                    _bootstrapError = null;
                  });
                  _bootstrap();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else {
      body = IndexedStack(
        index: _section.index,
        children: [
          DashboardPage(
            user: widget.user,
            onAddAccount: () => _select(AppSection.settings),
            onRecord: () => _select(AppSection.record),
            onSeeHistory: () => _select(AppSection.history),
            onSeeReminders: () => _select(AppSection.reminders),
          ),
          RecordPage(onRecorded: () => _select(AppSection.dashboard)),
          HistoryPage(onRecord: () => _select(AppSection.record)),
          const RemindersPage(),
          SettingsPage(user: widget.user),
        ],
      );
    }

    if (useDrawer) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: Text(titles[_section]!),
          leading: IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: AppDrawerMenu(
          selected: _section,
          onSelect: _select,
          onLogout: _logout,
        ),
        body: body,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Row(
        children: [
          AppSidebar(
            expanded: _expanded,
            selected: _section,
            onSelect: _select,
            onLogout: _logout,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
