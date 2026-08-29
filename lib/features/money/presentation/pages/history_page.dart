import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/money_format.dart';
import '../../data/account_service.dart';
import '../../data/category_service.dart';
import '../../data/transaction_service.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/money_transaction.dart';
import '../money_icons.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';
import '../widgets/transaction_detail.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.onRecord});

  final VoidCallback? onRecord;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _search = TextEditingController();
  TxType? _typeFilter;
  String? _categoryFilter;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _newestFirst = true;
  int _page = 0;
  static const _pageSize = 20;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<MoneyTransaction> _filter(List<MoneyTransaction> items) {
    final query = _search.text.trim().toLowerCase();
    final from = _fromDate == null
        ? null
        : DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
    final to = _toDate == null
        ? null
        : DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59);
    final filtered = items.where((tx) {
      if (_typeFilter != null && tx.type != _typeFilter) return false;
      if (_categoryFilter != null && tx.categoryId != _categoryFilter) {
        return false;
      }
      if (from != null && tx.transactionDate < from.millisecondsSinceEpoch) {
        return false;
      }
      if (to != null && tx.transactionDate > to.millisecondsSinceEpoch) {
        return false;
      }
      if (query.isEmpty) return true;
      return tx.displayDescription.toLowerCase().contains(query) ||
          tx.type.label.toLowerCase().contains(query);
    }).toList();
    if (!_newestFirst) {
      return filtered.reversed.toList();
    }
    return filtered;
  }

  Future<void> _pickRange({required bool from}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      _page = 0;
    });
  }

  void _openDetail(
    MoneyTransaction tx,
    List<Account> accounts,
    List<Category> categories,
  ) {
    showTransactionDetail(
      context,
      tx: tx,
      accounts: accounts,
      categories: categories,
      onDelete: () => _delete(tx),
    );
  }

  Future<void> _delete(MoneyTransaction tx) async {
    final ok = await confirmAction(
      context,
      title: 'Delete transaction',
      message: 'This will reverse its effect on your balances.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!ok) return;
    try {
      await TransactionService.instance.delete(tx);
      if (mounted) showAppMessage(context, 'Transaction deleted.');
    } catch (error) {
      if (mounted) showAppError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MoneyTransaction>>(
      stream: TransactionService.instance.watch(),
      builder: (context, txSnap) {
        return StreamBuilder<List<Account>>(
          stream: AccountService.instance.watch(),
          builder: (context, accountSnap) {
            return StreamBuilder<List<Category>>(
              stream: CategoryService.instance.watch(),
              builder: (context, categorySnap) {
                if (txSnap.connectionState == ConnectionState.waiting &&
                    !txSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = txSnap.data ?? [];
                final accounts = {
                  for (final item in accountSnap.data ?? <Account>[])
                    item.id: item,
                };
                final categories = {
                  for (final item in categorySnap.data ?? <Category>[])
                    item.id: item,
                };
                final filtered = _filter(all);
                final pages = (filtered.length / _pageSize).ceil().clamp(
                  1,
                  999,
                );
                final currentPage = _page >= pages ? 0 : _page;
                final slice = filtered
                    .skip(currentPage * _pageSize)
                    .take(_pageSize);

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.xl,
                            AppSpacing.md,
                          ),
                          child: Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.md,
                            children: [
                              SizedBox(
                                width: 260,
                                child: TextField(
                                  controller: _search,
                                  decoration: const InputDecoration(
                                    hintText: 'Search',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (_) => setState(() => _page = 0),
                                ),
                              ),
                              DropdownButton<TxType?>(
                                value: _typeFilter,
                                hint: const Text('Type'),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All types'),
                                  ),
                                  ...TxType.values.map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.label),
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _typeFilter = value;
                                  _page = 0;
                                }),
                              ),
                              DropdownButton<String?>(
                                value: _categoryFilter,
                                hint: const Text('Category'),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('All categories'),
                                  ),
                                  ...categories.values.map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(() {
                                  _categoryFilter = value;
                                  _page = 0;
                                }),
                              ),
                              TextButton.icon(
                                onPressed: () => _pickRange(from: true),
                                icon: const Icon(Icons.event),
                                label: Text(
                                  _fromDate == null
                                      ? 'From'
                                      : AppDateFormat.short(_fromDate!),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _pickRange(from: false),
                                icon: const Icon(Icons.event_available),
                                label: Text(
                                  _toDate == null
                                      ? 'To'
                                      : AppDateFormat.short(_toDate!),
                                ),
                              ),
                              if (_fromDate != null || _toDate != null)
                                TextButton(
                                  onPressed: () => setState(() {
                                    _fromDate = null;
                                    _toDate = null;
                                    _page = 0;
                                  }),
                                  child: const Text('Clear dates'),
                                ),
                              TextButton(
                                onPressed: () => setState(() {
                                  _newestFirst = !_newestFirst;
                                  _page = 0;
                                }),
                                child: Text(
                                  _newestFirst ? 'Newest first' : 'Oldest first',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: all.isEmpty
                              ? EmptyState(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'No transactions yet.',
                                  message:
                                      'Start recording your financial activity.',
                                  actionLabel: widget.onRecord == null
                                      ? null
                                      : 'Record transaction',
                                  onAction: widget.onRecord,
                                )
                              : filtered.isEmpty
                              ? const EmptyState(
                                  icon: Icons.filter_alt_outlined,
                                  title: 'No matching transactions',
                                  message: 'Try a different search or filter.',
                                )
                              : Breakpoints.isMobile(context)
                              ? ListView(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  children: [
                                    for (final tx in slice)
                                      _HistoryCard(
                                        tx: tx,
                                        category: categories[tx.categoryId],
                                        onOpen: () => _openDetail(
                                          tx,
                                          accounts.values.toList(),
                                          categories.values.toList(),
                                        ),
                                        onDelete: canDeleteTransaction(tx.type)
                                            ? () => _delete(tx)
                                            : null,
                                      ),
                                    _Pager(
                                      page: currentPage,
                                      pages: pages,
                                      onChanged: (value) =>
                                          setState(() => _page = value),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 720,
                                          ),
                                          child: DataTable(
                                            headingTextStyle: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            columns: const [
                                              DataColumn(label: Text('Date')),
                                              DataColumn(
                                                label: Text('Description'),
                                              ),
                                              DataColumn(label: Text('Type')),
                                              DataColumn(
                                                label: Text('Category'),
                                              ),
                                              DataColumn(
                                                label: Text('Account'),
                                              ),
                                              DataColumn(
                                                label: Text('Amount'),
                                                numeric: true,
                                              ),
                                              DataColumn(label: Text('')),
                                            ],
                                            rows: [
                                              for (final tx in slice)
                                                DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text(
                                                        AppDateFormat.short(
                                                          AppDateFormat.fromMillis(
                                                            tx.transactionDate,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        tx.displayDescription,
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(tx.type.label),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        categories[tx
                                                                    .categoryId]
                                                                ?.name ??
                                                            '—',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        accounts[tx.accountId]
                                                                ?.name ??
                                                            accounts[tx
                                                                    .fromAccountId]
                                                                ?.name ??
                                                            '—',
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        MoneyFormat.format(
                                                          tx.amount,
                                                          currency: tx.currency,
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              tx.direction ==
                                                                  TxDirection
                                                                      .expense
                                                              ? AppColors.error
                                                              : AppColors
                                                                    .success,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            tooltip: 'Details',
                                                            onPressed: () =>
                                                                _openDetail(
                                                                  tx,
                                                                  accounts
                                                                      .values
                                                                      .toList(),
                                                                  categories
                                                                      .values
                                                                      .toList(),
                                                                ),
                                                            icon: const Icon(
                                                              Icons
                                                                  .visibility_outlined,
                                                            ),
                                                          ),
                                                          if (canDeleteTransaction(
                                                            tx.type,
                                                          ))
                                                            IconButton(
                                                              tooltip: 'Delete',
                                                              onPressed: () =>
                                                                  _delete(tx),
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      _Pager(
                                        page: currentPage,
                                        pages: pages,
                                        onChanged: (value) =>
                                            setState(() => _page = value),
                                      ),
                                    ],
                                  ),
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
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.tx,
    required this.onOpen,
    this.onDelete,
    this.category,
  });

  final MoneyTransaction tx;
  final Category? category;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onOpen,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(txIcon(tx.type)),
          title: Text(tx.displayDescription),
          subtitle: Text(
            '${tx.type.label} • ${category?.name ?? '—'} • ${AppDateFormat.short(AppDateFormat.fromMillis(tx.transactionDate))}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MoneyFormat.format(tx.amount, currency: tx.currency),
                style: TextStyle(
                  color: tx.direction == TxDirection.expense
                      ? AppColors.error
                      : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.pages,
    required this.onChanged,
  });

  final int page;
  final int pages;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (pages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: page > 0 ? () => onChanged(page - 1) : null,
            child: const Text('Previous'),
          ),
          Text('${page + 1} / $pages'),
          TextButton(
            onPressed: page < pages - 1 ? () => onChanged(page + 1) : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
