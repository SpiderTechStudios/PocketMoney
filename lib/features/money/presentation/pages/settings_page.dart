import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../data/account_service.dart';
import '../../data/category_service.dart';
import '../../data/settings_service.dart';
import '../../data/user_workspace_service.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/user_settings.dart';
import '../money_icons.dart';
import '../widgets/account_form.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserWorkspaceService.instance.watchProfile(),
      builder: (context, profileSnap) {
        return StreamBuilder<UserSettings>(
          stream: SettingsService.instance.watch(),
          builder: (context, settingsSnap) {
            return StreamBuilder<List<Account>>(
              stream: AccountService.instance.watch(),
              builder: (context, accountSnap) {
                final profile = profileSnap.data;
                final settings = settingsSnap.data ?? UserSettings.defaults;
                final accounts = accountSnap.data ?? [];
                final currency = profile?.currency ?? settings.currency;
                final name = profile?.name ?? user.welcomeName;
                final email = profile?.email ?? user.email ?? '';

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryMuted,
                                backgroundImage:
                                    (profile?.photoUrl ?? user.photoUrl) != null
                                    ? NetworkImage(
                                        profile?.photoUrl ?? user.photoUrl!,
                                      )
                                    : null,
                                child:
                                    (profile?.photoUrl ?? user.photoUrl) == null
                                    ? Text(
                                        name.isEmpty
                                            ? '?'
                                            : name[0].toUpperCase(),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(email),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => _editProfile(
                                  context,
                                  name: name,
                                  currency: currency,
                                ),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Preferences',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            children: [
                              _PrefTile(
                                label: 'Currency',
                                value: settings.currency,
                                options: const [
                                  'TZS',
                                  'USD',
                                  'KES',
                                  'UGX',
                                  'EUR',
                                ],
                                onChanged: (value) => SettingsService.instance
                                    .update(settings.copyWith(currency: value)),
                              ),
                              _PrefTile(
                                label: 'Language',
                                value: settings.language,
                                options: const ['en', 'sw'],
                                onChanged: (value) => SettingsService.instance
                                    .update(settings.copyWith(language: value)),
                              ),
                              _PrefTile(
                                label: 'Theme',
                                value: settings.theme,
                                options: const ['system', 'light', 'dark'],
                                onChanged: (value) => SettingsService.instance
                                    .update(settings.copyWith(theme: value)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Notifications'),
                                value: settings.notificationsEnabled,
                                onChanged: (value) =>
                                    SettingsService.instance.update(
                                      settings.copyWith(
                                        notificationsEnabled: value,
                                      ),
                                    ),
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Reminders'),
                                value: settings.remindersEnabled,
                                onChanged: (value) =>
                                    SettingsService.instance.update(
                                      settings.copyWith(
                                        remindersEnabled: value,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Accounts',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  showAccountForm(context, currency: currency),
                              child: const Text('Add account'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (accounts.isEmpty)
                          EmptyState(
                            icon: Icons.account_balance_wallet_outlined,
                            title: "You haven't added an account yet.",
                            message:
                                'Add cash, mobile money, or a bank account.',
                            actionLabel: 'Add account',
                            onAction: () =>
                                showAccountForm(context, currency: currency),
                          )
                        else
                          ...accounts.map((account) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: AppCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(accountIcon(account.type)),
                                  title: Text(account.name),
                                  subtitle: Text(
                                    '${account.type.label} • ${account.isActive ? 'Active' : 'Archived'}\n${MoneyFormat.format(account.balance, currency: account.currency)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () => showAccountForm(
                                          context,
                                          account: account,
                                          currency: currency,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: account.isActive
                                            ? 'Deactivate'
                                            : 'Reactivate',
                                        onPressed: () =>
                                            AccountService.instance.setActive(
                                              id: account.id,
                                              isActive: !account.isActive,
                                            ),
                                        icon: Icon(
                                          account.isActive
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Custom category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => _addCategory(context),
                          child: const Text('Add category'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _editProfile(
    BuildContext context, {
    required String name,
    required String currency,
  }) async {
    final controller = TextEditingController(text: name);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: AuthTextField(
            label: 'Full name',
            controller: controller,
            validator: Validators.fullName,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved == true && controller.text.trim().isNotEmpty) {
      try {
        await UserWorkspaceService.instance.updateProfile(
          name: controller.text.trim(),
        );
        if (context.mounted) showAppMessage(context, 'Profile updated.');
      } catch (error) {
        if (context.mounted) showAppError(context, error);
      }
    }
    controller.dispose();
  }

  Future<void> _addCategory(BuildContext context) async {
    final name = TextEditingController();
    var type = CategoryKind.expense;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthTextField(label: 'Name', controller: name),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<CategoryKind>(
                    initialValue: type,
                    items: const [
                      DropdownMenuItem(
                        value: CategoryKind.expense,
                        child: Text('Expense'),
                      ),
                      DropdownMenuItem(
                        value: CategoryKind.income,
                        child: Text('Income'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => type = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      try {
        await CategoryService.instance.create(name: name.text, type: type);
        if (context.mounted) showAppMessage(context, 'Category added.');
      } catch (error) {
        if (context.mounted) showAppError(context, error);
      }
    }
    name.dispose();
  }
}

class _PrefTile extends StatelessWidget {
  const _PrefTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: DropdownButton<String>(
        value: options.contains(value) ? value : options.first,
        items: options
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (item) {
          if (item != null) onChanged(item);
        },
      ),
    );
  }
}
