import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/forgot_password_success_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../presentation/screens/home.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordSuccess = '/forgot-password-success';
  static const String home = '/home';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.register:
        return _fade(const RegisterPage(), settings);
      case AppRoutes.forgotPassword:
        return _fade(const ForgotPasswordPage(), settings);
      case AppRoutes.forgotPasswordSuccess:
        final email = settings.arguments is String
            ? settings.arguments as String
            : '';
        return _fade(ForgotPasswordSuccessPage(email: email), settings);
      case AppRoutes.home:
        return _fade(const HomeScreen(), settings);
      case AppRoutes.login:
      case '/':
      default:
        return _fade(const LoginPage(), settings);
    }
  }

  static PageRoute<T> _fade<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}
