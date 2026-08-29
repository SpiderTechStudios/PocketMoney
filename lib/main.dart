import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const PocketMoneyApp());
}

class PocketMoneyApp extends StatelessWidget {
  const PocketMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketMoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: const AppScrollBehavior(),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
