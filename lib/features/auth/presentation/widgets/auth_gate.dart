import 'package:flutter/material.dart';

import '../../domain/models/app_user.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../features/app_shell/app_shell.dart';
import 'auth_splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.authStateChanges});

  /// Override in tests so Firebase does not need to be initialized.
  final Stream<AppUser?>? authStateChanges;

  static final GlobalKey<NavigatorState> unauthNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final stream =
        authStateChanges ?? FirebaseAuthService.instance.authStateChanges;

    return StreamBuilder<AppUser?>(
      stream: stream,
      builder: (context, snapshot) {
        final cachedUser = authStateChanges == null
            ? FirebaseAuthService.instance.currentUser
            : null;
        final user = snapshot.data ?? cachedUser;

        final waitingForAuth =
            snapshot.connectionState == ConnectionState.waiting &&
            user == null &&
            !snapshot.hasError;

        if (waitingForAuth) {
          return const AuthSplashScreen();
        }

        if (user != null) {
          return AppShell(user: user);
        }

        return Navigator(
          key: unauthNavigatorKey,
          initialRoute: AppRoutes.login,
          onGenerateRoute: AppRouter.onGenerateAuthRoute,
        );
      },
    );
  }
}
