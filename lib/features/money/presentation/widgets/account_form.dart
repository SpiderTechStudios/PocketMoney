import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../../data/account_service.dart';
import '../../domain/models/account.dart';
import 'feedback.dart';

Future<void> showAccountForm(
  BuildContext context, {
  Account? account,
  required String currency,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
        ),
        child: _AccountForm(account: account, currency: currency),
      );
    },
  );
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({required this.currency, this.account});

  final Account? account;
  final String currency;

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _balance;
  late final TextEditingController _provider;
  late AccountType _type;
  bool _saving = false;

  bool get _editing => widget.account != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.account?.name ?? '');
    _balance = TextEditingController(
      text: widget.account == null ? '' : widget.account!.balance.toString(),
    );
    _provider = TextEditingController(text: widget.account?.provider ?? '');
    _type = widget.account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      if (_editing) {
        await AccountService.instance.update(
          id: widget.account!.id,
          name: _name.text,
          type: _type,
          provider: _provider.text,
        );
      } else {
        await AccountService.instance.create(
          name: _name.text,
          type: _type,
          openingBalance: MoneyFormat.parse(_balance.text) ?? 0,
          currency: widget.currency,
          provider: _provider.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppMessage(context, _editing ? 'Account updated.' : 'Account added.');
    } catch (error) {
      if (!mounted) return;
      showAppError(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _editing ? 'Edit account' : 'Add account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthTextField(
              label: 'Name',
              hint: 'Cash, M-Pesa, CRDB…',
              controller: _name,
              validator: (value) => Validators.requiredField(value, 'Name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: AccountType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            if (_type == AccountType.mobileMoney) ...[
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Provider',
                hint: 'mpesa, tigopesa…',
                controller: _provider,
              ),
            ],
            if (!_editing) ...[
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Current / opening balance',
                hint: '0',
                controller: _balance,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = MoneyFormat.parse(value);
                  if (parsed == null) return 'Enter a valid amount';
                  if (parsed < 0) return 'Balance cannot be negative';
                  return null;
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _editing ? 'Save changes' : 'Add account',
              isLoading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
