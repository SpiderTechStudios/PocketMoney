import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../data/transaction_service.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/money_transaction.dart';
import '../money_icons.dart';
import 'feedback.dart';

bool canEditTransaction(TxType type) {
  return type != TxType.lent &&
      type != TxType.borrowed &&
      type != TxType.debtPayment;
}

bool canDeleteTransaction(TxType type) {
  return type != TxType.lent &&
      type != TxType.borrowed &&
      type != TxType.debtPayment;
}

Future<void> showTransactionDetail(
  BuildContext context, {
  required MoneyTransaction tx,
  required List<Account> accounts,
  required List<Category> categories,
  required VoidCallback onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _TransactionDetailSheet(
      tx: tx,
      accounts: accounts,
      categories: categories,
      onDelete: onDelete,
    ),
  );
}

class _TransactionDetailSheet extends StatefulWidget {
  const _TransactionDetailSheet({
    required this.tx,
    required this.accounts,
    required this.categories,
    required this.onDelete,
  });

  final MoneyTransaction tx;
  final List<Account> accounts;
  final List<Category> categories;
  final VoidCallback onDelete;

  @override
  State<_TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<_TransactionDetailSheet> {
  late bool _editing;

  @override
  void initState() {
    super.initState();
    _editing = false;
  }

  String _accountName(String? id) {
    if (id == null) return '—';
    return widget.accounts
        .where((item) => item.id == id)
        .map((item) => item.name)
        .firstOrNull ??
        '—';
  }

  String _categoryName(String? id) {
    if (id == null) return '—';
    return widget.categories
        .where((item) => item.id == id)
        .map((item) => item.name)
        .firstOrNull ??
        '—';
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return _EditTransactionForm(
        tx: widget.tx,
        accounts: widget.accounts,
        categories: widget.categories,
        onCancel: () => setState(() => _editing = false),
      );
    }

    final tx = widget.tx;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(txIcon(tx.type)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  tx.displayDescription,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Amount',
            value: MoneyFormat.format(tx.amount, currency: tx.currency),
          ),
          _DetailRow(label: 'Type', value: tx.type.label),
          _DetailRow(label: 'Category', value: _categoryName(tx.categoryId)),
          if (tx.type == TxType.transfer) ...[
            _DetailRow(label: 'From', value: _accountName(tx.fromAccountId)),
            _DetailRow(label: 'To', value: _accountName(tx.toAccountId)),
            if (tx.fee != null)
              _DetailRow(
                label: 'Fee',
                value: MoneyFormat.format(
                  tx.fee!.amount,
                  currency: tx.fee!.currency,
                ),
              ),
          ] else
            _DetailRow(label: 'Account', value: _accountName(tx.accountId)),
          _DetailRow(
            label: 'Date',
            value: AppDateFormat.short(
              AppDateFormat.fromMillis(tx.transactionDate),
            ),
          ),
          if (tx.personName != null)
            _DetailRow(label: 'Person', value: tx.personName!),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              if (canEditTransaction(tx.type))
                OutlinedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              if (canDeleteTransaction(tx.type))
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _EditTransactionForm extends StatefulWidget {
  const _EditTransactionForm({
    required this.tx,
    required this.accounts,
    required this.categories,
    required this.onCancel,
  });

  final MoneyTransaction tx;
  final List<Account> accounts;
  final List<Category> categories;
  final VoidCallback onCancel;

  @override
  State<_EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<_EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late final TextEditingController _fee;
  late final TextEditingController _feeDescription;
  late DateTime _date;
  String? _accountId;
  String? _fromAccountId;
  String? _toAccountId;
  String? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.tx;
    _amount = TextEditingController(text: tx.amount.toString());
    _description = TextEditingController(text: tx.description ?? '');
    _fee = TextEditingController(text: tx.fee?.amount.toString() ?? '');
    _feeDescription = TextEditingController(
      text: tx.fee?.description ?? 'Transfer fee',
    );
    _date = AppDateFormat.fromMillis(tx.transactionDate);
    _accountId = tx.accountId;
    _fromAccountId = tx.fromAccountId;
    _toAccountId = tx.toAccountId;
    _categoryId = tx.categoryId;
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _fee.dispose();
    _feeDescription.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = MoneyFormat.parse(_amount.text);
    if (amount == null || amount <= 0) {
      showAppError(context, 'Enter a valid amount.');
      return;
    }
    if (widget.tx.type == TxType.transfer && _fromAccountId == _toAccountId) {
      showAppError(context, 'From and to accounts must be different.');
      return;
    }

    setState(() => _saving = true);
    try {
      final feeAmount = MoneyFormat.parse(_fee.text) ?? 0;
      final next = MoneyTransaction(
        id: widget.tx.id,
        type: widget.tx.type,
        direction: widget.tx.direction,
        amount: amount,
        currency: widget.tx.currency,
        transactionDate: DateTime(
          _date.year,
          _date.month,
          _date.day,
        ).millisecondsSinceEpoch,
        accountId: _accountId,
        fromAccountId: _fromAccountId,
        toAccountId: _toAccountId,
        categoryId: _categoryId,
        description: _description.text.trim(),
        fee: widget.tx.type == TxType.transfer && feeAmount > 0
            ? TransferFee(
                amount: feeAmount,
                currency: widget.tx.currency,
                categoryId: 'transaction_fee',
                description: _feeDescription.text.trim().isEmpty
                    ? 'Transfer fee'
                    : _feeDescription.text.trim(),
              )
            : null,
        createdAt: widget.tx.createdAt,
      );
      await TransactionService.instance.update(widget.tx, next);
      if (!mounted) return;
      Navigator.pop(context);
      showAppMessage(context, 'Transaction updated.');
    } catch (error) {
      if (!mounted) return;
      showAppError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAccounts = widget.accounts
        .where((item) => item.isActive)
        .toList();
    final filteredCategories = widget.categories.where((item) {
      if (!item.isActive) return false;
      if (widget.tx.direction == TxDirection.income) {
        return item.type == CategoryKind.income;
      }
      if (widget.tx.direction == TxDirection.expense) {
        return item.type == CategoryKind.expense;
      }
      return true;
    }).toList();

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
                'Edit transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthTextField(
                label: 'Amount',
                controller: _amount,
                keyboardType: TextInputType.number,
                validator: Validators.amount,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (widget.tx.type == TxType.transfer) ...[
                DropdownButtonFormField<String>(
                  initialValue: activeAccounts.any((a) => a.id == _fromAccountId)
                      ? _fromAccountId
                      : null,
                  decoration: const InputDecoration(labelText: 'From account'),
                  items: activeAccounts
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Select an account' : null,
                  onChanged: (value) => setState(() => _fromAccountId = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: activeAccounts.any((a) => a.id == _toAccountId)
                      ? _toAccountId
                      : null,
                  decoration: const InputDecoration(labelText: 'To account'),
                  items: activeAccounts
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  validator: (value) {
                    if (value == null) return 'Select an account';
                    if (value == _fromAccountId) {
                      return 'Accounts must be different';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() => _toAccountId = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: 'Fee (optional)',
                  controller: _fee,
                  keyboardType: TextInputType.number,
                  validator: Validators.optionalNonNegative,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: 'Fee description',
                  controller: _feeDescription,
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: activeAccounts.any((a) => a.id == _accountId)
                      ? _accountId
                      : null,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: activeAccounts
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Select an account' : null,
                  onChanged: (value) => setState(() => _accountId = value),
                ),
                if (widget.tx.direction == TxDirection.income ||
                    widget.tx.direction == TxDirection.expense) ...[
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: filteredCategories.any(
                      (item) => item.id == _categoryId,
                    )
                        ? _categoryId
                        : null,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: filteredCategories
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Select a category' : null,
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(label: 'Description', controller: _description),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(_date.toLocal().toString().split(' ').first),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2018),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              PrimaryButton(
                label: 'Save changes',
                isLoading: _saving,
                onPressed: _save,
              ),
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
