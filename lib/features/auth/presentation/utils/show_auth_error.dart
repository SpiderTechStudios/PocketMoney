import 'package:flutter/material.dart';

import '../../domain/auth_failure.dart';

void showAuthError(BuildContext context, Object error) {
  if (error is AuthCancelledException) return;

  String message;
  try {
    message = error is AuthFailure
        ? error.message
        : AuthFailure.from(error).message;
  } on AuthCancelledException {
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showAuthMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
