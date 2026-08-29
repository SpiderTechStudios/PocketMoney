import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? fullName(String? value) {
    final requiredError = requiredField(value, 'Full name');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 2) {
      return 'Please enter your full name';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, 'Email');
    if (requiredError != null) return requiredError;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, 'Password');
    if (requiredError != null) return requiredError;
    if (value!.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? amount(String? value, {String fieldName = 'Amount'}) {
    final requiredError = requiredField(value, fieldName);
    if (requiredError != null) return requiredError;
    final parsed = num.tryParse(value!.trim().replaceAll(',', ''));
    if (parsed == null) return 'Enter a valid ${fieldName.toLowerCase()}';
    if (parsed <= 0) return '$fieldName must be greater than zero';
    return null;
  }

  static String? optionalNonNegative(
    String? value, {
    String fieldName = 'Fee',
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = num.tryParse(value.trim().replaceAll(',', ''));
    if (parsed == null) return 'Enter a valid ${fieldName.toLowerCase()}';
    if (parsed < 0) return '$fieldName cannot be negative';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = requiredField(value, 'Confirm password');
    if (requiredError != null) return requiredError;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
