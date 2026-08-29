import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/domain/models/app_user.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (_) {
      // Browser local persistence is the Firebase web default.
    }
  }

  runApp(const PocketMoneyApp());
}

class PocketMoneyApp extends StatelessWidget {
  const PocketMoneyApp({super.key, this.authStateChanges});

  /// Used by widget tests to avoid initializing Firebase.
  final Stream<AppUser?>? authStateChanges;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketMoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      scrollBehavior: const AppScrollBehavior(),
      home: AuthGate(authStateChanges: authStateChanges),
    );
  }
}
