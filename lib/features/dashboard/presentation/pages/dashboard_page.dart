import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../money/data/account_service.dart';
import '../../../money/data/debt_service.dart';
import '../../../money/data/reminder_service.dart';
import '../../../money/data/settings_service.dart';
import '../../../money/data/transaction_service.dart';
import '../../../money/data/user_workspace_service.dart';
import '../../../money/domain/models/account.dart';
import '../../../money/domain/models/debt.dart';
import '../../../money/domain/models/money_transaction.dart';
import '../../../money/domain/models/reminder.dart';
import '../../../money/domain/models/user_settings.dart';
import '../../../money/presentation/money_icons.dart';
import '../../../money/presentation/widgets/account_form.dart';
import '../../../money/presentation/widgets/app_card.dart';
import '../../../money/presentation/widgets/empty_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.user,
    this.onAddAccount,
    this.onRecord,
    this.onSeeHistory,
    this.onSeeReminders,
    this.authActions,
  });

  final AppUser user;
  final VoidCallback? onAddAccount;
  final VoidCallback? onRecord;
  final VoidCallback? onSeeHistory;
  final VoidCallback? onSeeReminders;
  final Object? authActions;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserWorkspaceService.instance.watchProfile(),
      builder: (context, profileSnap) {
        final name = profileSnap.data?.name ?? widget.user.welcomeName;
        final currency = profileSnap.data?.currency ?? 'TZS';

        return StreamBuilder<List<Account>>(
          stream: AccountService.instance.watch(),
          builder: (context, accountSnap) {
            return StreamBuilder<DashboardSummary>(
              stream: SettingsService.instance.watchDashboard(),
              builder: (context, dashSnap) {
                return StreamBuilder<List<MoneyTransaction>>(
                  stream: TransactionService.instance.watch(),
                  builder: (context, txSnap) {
                    return StreamBuilder<List<Reminder>>(
                      stream: ReminderService.instance.watch(),
                      builder: (context, reminderSnap) {
                        return StreamBuilder<List<Debt>>(
                          stream: DebtService.instance.watch(),
                          builder: (context, debtSnap) {
                        if (accountSnap.connectionState ==
                                ConnectionState.waiting &&
                            !accountSnap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final accounts =
                            accountSnap.data
                                ?.where((item) => item.isActive)
                                .toList() ??
                            [];
                        final txs = txSnap.data ?? [];
                        final reminders = reminderSnap.data ?? [];
                        final summary =
                            dashSnap.data ?? const DashboardSummary();
                        final balance = accounts.fold<num>(
                          0,
                          (sum, item) => sum + item.balance,
                        );
                        final upcoming = reminders
                            .where((item) => item.isUpcoming)
                            .take(3)
                            .toList();
                        final openDebts = (debtSnap.data ?? [])
                            .where((item) => item.isOpen)
                            .toList();
                        Debt? nearestDue;
                        final dated = openDebts
                            .where((item) => item.dueDate != null)
                            .toList()
                          ..sort(
                            (a, b) => a.dueDate!.compareTo(b.dueDate!),
                          );
                        if (dated.isNotEmpty) nearestDue = dated.first;

                        return Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: ListView(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              children: [
                                Text(
                                  '${AppDateFormat.greeting()}, $name 👋',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  "Here's your financial overview.",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _BalanceCard(
                                  amount: balance,
                                  currency: currency,
                                  hidden: _hideBalance,
                                  onToggle: () => setState(
                                    () => _hideBalance = !_hideBalance,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _SummaryGrid(
                                  currency: currency,
                                  hidden: _hideBalance,
                                  income: summary.totalIncome,
                                  expenses: summary.totalExpenses,
                                  lent: summary.totalLent,
                                  borrowed: summary.totalBorrowed,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                _SectionTitle(
                                  title: 'My accounts',
                                  action: 'View all',
                                  onAction: widget.onAddAccount,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (accounts.isEmpty)
                                  EmptyState(
                                    icon: Icons.account_balance_wallet_outlined,
                                    title: "You haven't added an account yet.",
                                    message: 'Add cash, mobile money, or a bank account to start recording.',
                                    actionLabel: 'Add account',
                                    onAction: () => showAccountForm(
                                      context,
                                      currency: currency,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: AppSpacing.md,
                                    runSpacing: AppSpacing.md,
                                    children: [
                                      for (final account in accounts)
                                        SizedBox(
                                          width: 280,
                                          child: AppCard(
                                            onTap: () => showAccountForm(
                                              context,
                                              account: account,
                                              currency: currency,
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(
                                                accountIcon(account.type),
                                                color: AppColors.primary,
                                              ),
                                              title: Text(account.name),
                                              subtitle: Text(
                                                account.type.label,
                                              ),
                                              trailing: Text(
                                                _hideBalance
                                                    ? '••••'
                                                    : MoneyFormat.format(
                                                        account.balance,
                                                        currency: currency,
                                                      ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        width: 280,
                                        child: AppCard(
                                          onTap: () => showAccountForm(
                                            context,
                                            currency: currency,
                                          ),
                                          child: const ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Icon(
                                              Icons.add_circle_outline,
                                              color: AppColors.primary,
                                            ),
                                            title: Text('Add account'),
                                            subtitle: Text(
                                              'Cash, bank, or mobile money',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: AppSpacing.xl),
                                _SectionTitle(
                                  title: 'Recent transactions',
                                  action: 'View all',
                                  onAction: widget.onSeeHistory,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (txs.isEmpty)
                                  EmptyState(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'No transactions yet.',
                                    message: 'Start recording your financial activity.',
                                    actionLabel: 'Record transaction',
                                    onAction: widget.onRecord,
                                  )
                                else
                                  ...txs.take(6).map((tx) {
                                    final expense =
                                        tx.direction == TxDirection.expense ||
                                        tx.type == TxType.lent;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: AppCard(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(txIcon(tx.type)),
                                          title: Text(tx.displayDescription),
                                          subtitle: Text(
                                            '${tx.type.label} • ${AppDateFormat.relative(AppDateFormat.fromMillis(tx.transactionDate))}',
                                          ),
                                          trailing: Text(
                                            MoneyFormat.signed(
                                              expense ? -tx.amount : tx.amount,
                                              currency: tx.currency,
                                            ),
                                            style: TextStyle(
                                              color: expense
                                                  ? AppColors.error
                                                  : AppColors.success,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(height: AppSpacing.xl),
                                _SectionTitle(
                                  title: 'Upcoming reminders',
                                  action: 'View all',
                                  onAction: widget.onSeeReminders,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (upcoming.isEmpty)
                                  const Text('No upcoming reminders.')
                                else
                                  ...upcoming.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.sm,
                                      ),
                                      child: AppCard(
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Icon(
                                            reminderIcon(item.type),
                                          ),
                                          title: Text(item.title),
                                          subtitle: Text(
                                            'Due ${AppDateFormat.relative(AppDateFormat.fromMillis(item.reminderDate))}',
                                          ),
                                          trailing: item.amount == null
                                              ? null
                                              : Text(
                                                  MoneyFormat.format(
                                                    item.amount!,
                                                    currency:
                                                        item.currency ??
                                                        currency,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'Debts',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: [
                                    _MiniStat(
                                      title: "Money I'm owed",
                                      value: MoneyFormat.format(
                                        summary.totalLent,
                                        currency: currency,
                                      ),
                                    ),
                                    _MiniStat(
                                      title: 'Money I owe',
                                      value: MoneyFormat.format(
                                        summary.totalBorrowed,
                                        currency: currency,
                                      ),
                                    ),
                                    if (nearestDue != null)
                                      _MiniStat(
                                        title: nearestDue.type == DebtKind.lent
                                            ? 'Nearest collection'
                                            : 'Nearest repayment',
                                        value:
                                            '${MoneyFormat.format(nearestDue.remainingAmount, currency: currency)}\n${nearestDue.personName} • ${AppDateFormat.relative(AppDateFormat.fromMillis(nearestDue.dueDate!))}',
                                      ),
                                  ],
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
              },
            );
          },
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.amount,
    required this.currency,
    required this.hidden,
    required this.onToggle,
  });

  final num amount;
  final String currency;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandingBackground, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total balance',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.onBrandingMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hidden
                        ? '$currency ••••••'
                        : MoneyFormat.format(amount, currency: currency),
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: AppColors.onBranding),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: hidden ? 'Show balance' : 'Hide balance',
              onPressed: onToggle,
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.onBranding,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.currency,
    required this.hidden,
    required this.income,
    required this.expenses,
    required this.lent,
    required this.borrowed,
  });

  final String currency;
  final bool hidden;
  final num income;
  final num expenses;
  final num lent;
  final num borrowed;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Income', income, AppColors.success),
      ('Expenses', expenses, AppColors.error),
      ('Lent', lent, AppColors.primary),
      ('Borrowed', borrowed, AppColors.accent),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(
                width: wide
                    ? (constraints.maxWidth - AppSpacing.md * 3) / 4
                    : (constraints.maxWidth - AppSpacing.md) / 2,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hidden
                            ? '••••'
                            : MoneyFormat.format(item.$2, currency: currency),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: item.$3),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
