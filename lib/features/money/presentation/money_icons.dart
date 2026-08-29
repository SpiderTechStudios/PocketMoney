import 'package:flutter/material.dart';

import '../domain/models/account.dart';
import '../domain/models/money_transaction.dart';
import '../domain/models/reminder.dart';

IconData categoryIcon(String? name) {
  return switch (name) {
    'restaurant' => Icons.restaurant_rounded,
    'local_bar' => Icons.local_bar_rounded,
    'directions_bus' => Icons.directions_bus_rounded,
    'local_gas_station' => Icons.local_gas_station_rounded,
    'home' => Icons.home_rounded,
    'bolt' => Icons.bolt_rounded,
    'shopping_bag' => Icons.shopping_bag_rounded,
    'health_and_safety' => Icons.health_and_safety_rounded,
    'school' => Icons.school_rounded,
    'movie' => Icons.movie_rounded,
    'receipt_long' => Icons.receipt_long_rounded,
    'payments' => Icons.payments_rounded,
    'storefront' => Icons.storefront_rounded,
    'work' => Icons.work_rounded,
    'point_of_sale' => Icons.point_of_sale_rounded,
    'card_giftcard' => Icons.card_giftcard_rounded,
    'trending_up' => Icons.trending_up_rounded,
    'replay' => Icons.replay_rounded,
    'add_card' => Icons.add_card_rounded,
    _ => Icons.label_outline_rounded,
  };
}

IconData accountIcon(AccountType type) {
  return switch (type) {
    AccountType.cash => Icons.payments_rounded,
    AccountType.bank => Icons.account_balance_rounded,
    AccountType.mobileMoney => Icons.phone_iphone_rounded,
    AccountType.savings => Icons.savings_rounded,
    AccountType.other => Icons.wallet_rounded,
  };
}

IconData txIcon(TxType type) {
  return switch (type) {
    TxType.earned => Icons.south_west_rounded,
    TxType.sold => Icons.storefront_rounded,
    TxType.received => Icons.call_received_rounded,
    TxType.refund => Icons.replay_rounded,
    TxType.bought => Icons.shopping_bag_rounded,
    TxType.paid => Icons.payments_rounded,
    TxType.spent => Icons.north_east_rounded,
    TxType.borrowed => Icons.call_received_rounded,
    TxType.lent => Icons.call_made_rounded,
    TxType.debtPayment => Icons.handshake_rounded,
    TxType.transfer => Icons.swap_horiz_rounded,
    TxType.openingBalance => Icons.flag_rounded,
  };
}

IconData reminderIcon(ReminderType type) {
  return switch (type) {
    ReminderType.payment => Icons.payment_rounded,
    ReminderType.collection => Icons.savings_rounded,
    ReminderType.purchase => Icons.shopping_cart_rounded,
    ReminderType.general => Icons.notifications_rounded,
  };
}
