import 'package:flutter/material.dart';

import '../../../../core/errors/app_failure.dart';

void showAppError(BuildContext context, Object error) {
  final message = error is AppFailure
      ? error.message
      : error is String
      ? error
      : AppFailure.from(error).message;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
