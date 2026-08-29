import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../data/reminder_service.dart';
import '../../data/user_workspace_service.dart';
import '../../domain/models/reminder.dart';
import '../money_icons.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';

enum _ReminderFilter { all, upcoming, overdue, completed }

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  _ReminderFilter _filter = _ReminderFilter.all;

  Future<void> _openForm({Reminder? reminder, required String currency}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _ReminderForm(reminder: reminder, currency: currency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserWorkspaceService.instance.watchProfile(),
      builder: (context, profileSnap) {
        final currency = profileSnap.data?.currency ?? 'TZS';
        return StreamBuilder<List<Reminder>>(
          stream: ReminderService.instance.watch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? [];
            final visible = items.where((item) {
              return switch (_filter) {
                _ReminderFilter.all => !item.isCancelled,
                _ReminderFilter.upcoming => item.isUpcoming,
                _ReminderFilter.overdue => item.isOverdue,
                _ReminderFilter.completed => item.isCompleted,
              };
            }).toList();

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                for (final filter in _ReminderFilter.values)
                                  ChoiceChip(
                                    label: Text(
                                      filter.name[0].toUpperCase() +
                                          filter.name.substring(1),
                                    ),
                                    selected: _filter == filter,
                                    onSelected: (_) =>
                                        setState(() => _filter = filter),
                                  ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _openForm(currency: currency),
                            icon: const Icon(Icons.add),
                            label: const Text('Create'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? EmptyState(
                              icon: Icons.notifications_none,
                              title: 'No reminders yet.',
                              message: 'Create a reminder so you do not miss a payment.',
                              actionLabel: 'Create reminder',
                              onAction: () => _openForm(currency: currency),
                            )
                          : visible.isEmpty
                          ? const EmptyState(
                              icon: Icons.filter_alt_outlined,
                              title: 'Nothing here',
                              message: 'Try another filter.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final item = visible[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: AppCard(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        reminderIcon(item.type),
                                        color: item.isOverdue
                                            ? AppColors.error
                                            : AppColors.primary,
                                      ),
                                      title: Text(item.title),
                                      subtitle: Text(
                                        [
                                          item.type.label,
                                          AppDateFormat.relative(
                                            AppDateFormat.fromMillis(
                                              item.reminderDate,
                                            ),
                                          ),
                                          if (item.amount != null)
                                            MoneyFormat.format(
                                              item.amount!,
                                              currency:
                                                  item.currency ?? currency,
                                            ),
                                        ].join(' • '),
                                      ),
                                      trailing: Wrap(
                                        children: [
                                          if (!item.isCompleted &&
                                              !item.isCancelled) ...[
                                            IconButton(
                                              tooltip: 'Complete',
                                              onPressed: () => ReminderService
                                                  .instance
                                                  .complete(item.id),
                                              icon: const Icon(
                                                Icons.check_circle_outline,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Cancel',
                                              onPressed: () async {
                                                final ok = await confirmAction(
                                                  context,
                                                  title: 'Cancel reminder',
                                                  message:
                                                      'Cancel “${item.title}”?',
                                                  confirmLabel: 'Cancel it',
                                                );
                                                if (ok) {
                                                  await ReminderService
                                                      .instance
                                                      .cancel(item.id);
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.cancel_outlined,
                                              ),
                                            ),
                                          ],
                                          IconButton(
                                            tooltip: 'Edit',
                                            onPressed: () => _openForm(
                                              reminder: item,
                                              currency: currency,
                                            ),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete',
                                            onPressed: () async {
                                              final ok = await confirmAction(
                                                context,
                                                title: 'Delete reminder',
                                                message:
                                                    'Remove “${item.title}”?',
                                                confirmLabel: 'Delete',
                                                isDestructive: true,
                                              );
                                              if (ok) {
                                                await ReminderService.instance
                                                    .delete(item.id);
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReminderForm extends StatefulWidget {
  const _ReminderForm({required this.currency, this.reminder});

  final Reminder? reminder;
  final String currency;

  @override
  State<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<_ReminderForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late ReminderType _type;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.reminder?.title ?? '');
    _amount = TextEditingController(
      text: widget.reminder?.amount?.toString() ?? '',
    );
    _description = TextEditingController(
      text: widget.reminder?.description ?? '',
    );
    _type = widget.reminder?.type ?? ReminderType.payment;
    _date = widget.reminder == null
        ? DateTime.now().add(const Duration(days: 1))
        : AppDateFormat.fromMillis(widget.reminder!.reminderDate);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final amount = MoneyFormat.parse(_amount.text);
      if (widget.reminder == null) {
        await ReminderService.instance.create(
          title: _title.text,
          type: _type,
          reminderDate: _date.millisecondsSinceEpoch,
          amount: amount,
          currency: widget.currency,
          description: _description.text,
        );
      } else {
        await ReminderService.instance.update(
          Reminder(
            id: widget.reminder!.id,
            title: _title.text.trim(),
            type: _type,
            reminderDate: _date.millisecondsSinceEpoch,
            isCompleted: widget.reminder!.isCompleted,
            isCancelled: widget.reminder!.isCancelled,
            amount: amount,
            currency: widget.currency,
            description: _description.text.trim(),
            createdAt: widget.reminder!.createdAt,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      showAppMessage(context, 'Reminder saved.');
    } catch (error) {
      if (!mounted) return;
      showAppError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.reminder == null ? 'Create reminder' : 'Edit reminder',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthTextField(
                label: 'Title',
                controller: _title,
                validator: (value) => Validators.requiredField(value, 'Title'),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<ReminderType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ReminderType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Amount (optional)',
                controller: _amount,
                keyboardType: TextInputType.number,
                validator: Validators.optionalNonNegative,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(label: 'Description', controller: _description),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder date'),
                subtitle: Text(_date.toLocal().toString().split(' ').first),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              PrimaryButton(
                label: 'Save reminder',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
