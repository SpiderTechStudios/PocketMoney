import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../data/account_service.dart';
import '../../data/category_service.dart';
import '../../data/debt_service.dart';
import '../../data/transaction_service.dart';
import '../../data/user_workspace_service.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/debt.dart';
import '../../domain/models/money_transaction.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';
import '../widgets/account_form.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key, this.onRecorded});

  final VoidCallback? onRecorded;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _fee = TextEditingController();
  final _description = TextEditingController();
  final _feeDescription = TextEditingController();
  final _person = TextEditingController();
  final _phone = TextEditingController();

  TxType _type = TxType.bought;
  String? _accountId;
  String? _fromAccountId;
  String? _toAccountId;
  String? _categoryId;
  String? _debtId;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _saving = false;

  static const _recordTypes = [
    TxType.earned,
    TxType.sold,
    TxType.received,
    TxType.refund,
    TxType.bought,
    TxType.paid,
    TxType.spent,
    TxType.borrowed,
    TxType.lent,
    TxType.transfer,
    TxType.debtPayment,
  ];

  @override
  void dispose() {
    _amount.dispose();
    _fee.dispose();
    _description.dispose();
    _feeDescription.dispose();
    _person.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickDate({bool due = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: due ? (_dueDate ?? DateTime.now()) : _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() {
      if (due) {
        _dueDate = picked;
      } else {
        _date = picked;
      }
    });
  }

  Future<void> _submit({
    required String currency,
    required List<Account> accounts,
    required List<Debt> debts,
  }) async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = MoneyFormat.parse(_amount.text);
    if (amount == null || amount <= 0) {
      showAppError(context, 'Enter a valid amount.');
      return;
    }
    if (_type == TxType.transfer && _fromAccountId == _toAccountId) {
      showAppError(context, 'From and to accounts must be different.');
      return;
    }
    if ((_type.direction == TxDirection.income ||
            _type.direction == TxDirection.expense) &&
        (_categoryId == null || _categoryId!.isEmpty)) {
      showAppError(context, 'Please select a category.');
      return;
    }
    if (_type == TxType.debtPayment) {
      final debt = debts.where((item) => item.id == _debtId).firstOrNull;
      if (debt != null && amount > debt.remainingAmount) {
        showAppError(context, 'Payment cannot exceed the remaining amount.');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final millis = DateTime(
        _date.year,
        _date.month,
        _date.day,
      ).millisecondsSinceEpoch;

      if (_type == TxType.transfer) {
        await TransactionService.instance.recordTransfer(
          MoneyTransaction(
            id: '',
            type: _type,
            direction: TxDirection.transfer,
            amount: amount,
            currency: currency,
            transactionDate: millis,
            fromAccountId: _fromAccountId,
            toAccountId: _toAccountId,
            description: _description.text.trim(),
            fee: (MoneyFormat.parse(_fee.text) ?? 0) > 0
                ? TransferFee(
                    amount: MoneyFormat.parse(_fee.text)!,
                    currency: currency,
                    categoryId: 'transaction_fee',
                    description: _feeDescription.text.trim().isEmpty
                        ? 'Transfer fee'
                        : _feeDescription.text.trim(),
                  )
                : null,
          ),
        );
      } else if (_type == TxType.lent || _type == TxType.borrowed) {
        await TransactionService.instance.recordLentOrBorrowed(
          draft: MoneyTransaction(
            id: '',
            type: _type,
            direction: TxDirection.debt,
            amount: amount,
            currency: currency,
            transactionDate: millis,
            accountId: _accountId,
            description: _description.text.trim(),
          ),
          personName: _person.text,
          personPhone: _phone.text,
          dueDate: _dueDate?.millisecondsSinceEpoch,
        );
      } else if (_type == TxType.debtPayment) {
        final debt = debts.where((item) => item.id == _debtId).firstOrNull;
        if (debt == null) {
          throw 'Please select a debt.';
        }
        await DebtService.instance.recordPayment(
          debt: debt,
          amount: amount,
          accountId: _accountId ?? debt.accountId,
          paymentDate: millis,
        );
      } else {
        await TransactionService.instance.recordIncomeOrExpense(
          MoneyTransaction(
            id: '',
            type: _type,
            direction: _type.direction,
            amount: amount,
            currency: currency,
            transactionDate: millis,
            accountId: _accountId,
            categoryId: _categoryId,
            description: _description.text.trim(),
          ),
        );
      }

      if (!mounted) return;
      showAppMessage(context, 'Transaction recorded.');
      _amount.clear();
      _description.clear();
      _fee.clear();
      widget.onRecorded?.call();
    } catch (error) {
      if (!mounted) return;
      showAppError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserWorkspaceService.instance.watchProfile(),
      builder: (context, profileSnap) {
        final currency = profileSnap.data?.currency ?? 'TZS';
        return StreamBuilder<List<Account>>(
          stream: AccountService.instance.watch(),
          builder: (context, accountSnap) {
            return StreamBuilder<List<Category>>(
              stream: CategoryService.instance.watch(),
              builder: (context, categorySnap) {
                return StreamBuilder<List<Debt>>(
                  stream: DebtService.instance.watch(),
                  builder: (context, debtSnap) {
                    final accounts =
                        accountSnap.data
                            ?.where((item) => item.isActive)
                            .toList() ??
                        [];
                    final categories = categorySnap.data ?? [];
                    final debts =
                        debtSnap.data?.where((item) => item.isOpen).toList() ??
                        [];

                    if (accounts.isEmpty &&
                        accountSnap.connectionState !=
                            ConnectionState.waiting) {
                      return EmptyState(
                        icon: Icons.account_balance_wallet_outlined,
                        title: "You haven't added an account yet.",
                        message: 'Add an account before recording activity.',
                        actionLabel: 'Add account',
                        onAction: () =>
                            showAccountForm(context, currency: currency),
                      );
                    }

                    final kind = _type.direction;
                    final filteredCategories = categories.where((item) {
                      if (!item.isActive) return false;
                      if (kind == TxDirection.income) {
                        return item.type == CategoryKind.income;
                      }
                      if (kind == TxDirection.expense) {
                        return item.type == CategoryKind.expense;
                      }
                      return true;
                    }).toList();

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            children: [
                              Text(
                                'Record activity',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final type in _recordTypes)
                                    ChoiceChip(
                                      label: Text(type.label),
                                      selected: _type == type,
                                      onSelected: (_) => setState(() {
                                        _type = type;
                                        _categoryId = null;
                                        _debtId = null;
                                      }),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              AuthTextField(
                                label: 'Amount',
                                hint: '0',
                                controller: _amount,
                                keyboardType: TextInputType.number,
                                validator: Validators.amount,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (_type == TxType.transfer) ...[
                                _AccountDropdown(
                                  label: 'From account',
                                  value: _fromAccountId,
                                  accounts: accounts,
                                  onChanged: (value) =>
                                      setState(() => _fromAccountId = value),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _AccountDropdown(
                                  label: 'To account',
                                  value: _toAccountId,
                                  accounts: accounts,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Select an account';
                                    }
                                    if (value == _fromAccountId) {
                                      return 'Accounts must be different';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) =>
                                      setState(() => _toAccountId = value),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Fee (optional)',
                                  hint: '0',
                                  controller: _fee,
                                  keyboardType: TextInputType.number,
                                  validator: Validators.optionalNonNegative,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Fee description',
                                  hint: 'Transfer fee',
                                  controller: _feeDescription,
                                ),
                              ] else if (_type == TxType.debtPayment) ...[
                                DropdownButtonFormField<String>(
                                  initialValue:
                                      debts.any((d) => d.id == _debtId)
                                      ? _debtId
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Debt',
                                  ),
                                  items: debts
                                      .map(
                                        (debt) => DropdownMenuItem(
                                          value: debt.id,
                                          child: Text(
                                            '${debt.personName} • ${debt.remainingAmount}',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  validator: (value) =>
                                      value == null ? 'Select a debt' : null,
                                  onChanged: (value) =>
                                      setState(() => _debtId = value),
                                ),
                                if (_debtId != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'Remaining: ${MoneyFormat.format(debts.where((item) => item.id == _debtId).firstOrNull?.remainingAmount ?? 0, currency: currency)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.lg),
                                _AccountDropdown(
                                  label: 'Account',
                                  value: _accountId,
                                  accounts: accounts,
                                  onChanged: (value) =>
                                      setState(() => _accountId = value),
                                ),
                              ] else ...[
                                _AccountDropdown(
                                  label: 'Account',
                                  value: _accountId,
                                  accounts: accounts,
                                  onChanged: (value) =>
                                      setState(() => _accountId = value),
                                ),
                                if (kind == TxDirection.income ||
                                    kind == TxDirection.expense) ...[
                                  const SizedBox(height: AppSpacing.lg),
                                  DropdownButtonFormField<String>(
                                    initialValue:
                                        filteredCategories.any(
                                          (item) => item.id == _categoryId,
                                        )
                                        ? _categoryId
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                    ),
                                    items: filteredCategories
                                        .map(
                                          (item) => DropdownMenuItem(
                                            value: item.id,
                                            child: Text(item.name),
                                          ),
                                        )
                                        .toList(),
                                    validator: (value) => value == null
                                        ? 'Select a category'
                                        : null,
                                    onChanged: (value) =>
                                        setState(() => _categoryId = value),
                                  ),
                                ],
                              ],
                              if (_type == TxType.lent ||
                                  _type == TxType.borrowed) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Person name',
                                  controller: _person,
                                  validator: (value) =>
                                      Validators.requiredField(value, 'Name'),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AuthTextField(
                                  label: 'Phone (optional)',
                                  controller: _phone,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Due date'),
                                  subtitle: Text(
                                    _dueDate == null
                                        ? 'Optional'
                                        : _dueDate!
                                              .toLocal()
                                              .toString()
                                              .split(' ')
                                              .first,
                                  ),
                                  trailing: const Icon(Icons.event),
                                  onTap: () => _pickDate(due: true),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.lg),
                              AuthTextField(
                                label: 'Description',
                                hint: 'What was this for?',
                                controller: _description,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Date'),
                                subtitle: Text(
                                  _date.toLocal().toString().split(' ').first,
                                ),
                                trailing: const Icon(Icons.event),
                                onTap: _pickDate,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              PrimaryButton(
                                label: 'Save record',
                                isLoading: _saving,
                                onPressed: () => _submit(
                                  currency: currency,
                                  accounts: accounts,
                                  debts: debts,
                                ),
                              ),
                            ],
                          ),
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
  }
}

class _AccountDropdown extends StatelessWidget {
  const _AccountDropdown({
    required this.label,
    required this.value,
    required this.accounts,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? value;
  final List<Account> accounts;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final selected = accounts.any((item) => item.id == value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: InputDecoration(labelText: label),
      items: accounts
          .map(
            (item) => DropdownMenuItem(value: item.id, child: Text(item.name)),
          )
          .toList(),
      validator:
          validator ?? (item) => item == null ? 'Select an account' : null,
      onChanged: onChanged,
    );
  }
}
