import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketmoney/core/routing/app_router.dart';
import 'package:pocketmoney/core/theme/app_theme.dart';
import 'package:pocketmoney/features/auth/presentation/controllers/auth_actions.dart';
import 'package:pocketmoney/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:pocketmoney/features/auth/presentation/pages/forgot_password_success_page.dart';
import 'package:pocketmoney/features/auth/presentation/pages/login_page.dart';
import 'package:pocketmoney/features/auth/presentation/pages/register_page.dart';
import 'package:pocketmoney/main.dart';

class _InstantAuthActions extends AuthActions {
  const _InstantAuthActions();

  @override
  Future<void> onForgotPassword({required String email}) async {}

  @override
  Future<void> onResendResetEmail({required String email}) async {}
}

void main() {
  Future<void> pumpAtSize(
    WidgetTester tester, {
    required Size size,
    required Widget app,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  Widget wrapPage(Widget page) {
    return MaterialApp(
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: page,
    );
  }

  testWidgets('app launches on the login screen', (tester) async {
    await tester.pumpWidget(const PocketMoneyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('login shows validation errors for empty fields', (tester) async {
    await tester.pumpWidget(const PocketMoneyApp());

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('login navigates to registration', (tester) async {
    await tester.pumpWidget(const PocketMoneyApp());

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
  });

  testWidgets('login navigates to forgot password', (tester) async {
    await tester.pumpWidget(const PocketMoneyApp());

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot your password?'), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);
  });

  testWidgets('registration shows validation errors', (tester) async {
    await tester.pumpWidget(wrapPage(const RegisterPage()));

    await tester.ensureVisible(find.text('Sign Up'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    expect(find.text('Full name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Confirm password is required'), findsOneWidget);
  });

  testWidgets('forgot password sends user to the success screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapPage(const ForgotPasswordPage(authActions: _InstantAuthActions())),
    );

    await tester.enterText(find.byType(TextFormField), 'ada@pocketmoney.app');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('ada@pocketmoney.app'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  const sizes = [
    Size(390, 844),
    Size(768, 1024),
    Size(1440, 900),
    Size(800, 560),
  ];

  for (final size in sizes) {
    testWidgets(
      'auth screens do not overflow at ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await pumpAtSize(tester, size: size, app: wrapPage(const LoginPage()));
        expect(find.byType(LoginPage), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpAtSize(
          tester,
          size: size,
          app: wrapPage(const RegisterPage()),
        );
        expect(find.byType(RegisterPage), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpAtSize(
          tester,
          size: size,
          app: wrapPage(const ForgotPasswordPage()),
        );
        expect(find.byType(ForgotPasswordPage), findsOneWidget);
        expect(tester.takeException(), isNull);

        await pumpAtSize(
          tester,
          size: size,
          app: wrapPage(
            const ForgotPasswordSuccessPage(email: 'ada@pocketmoney.app'),
          ),
        );
        expect(find.byType(ForgotPasswordSuccessPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
