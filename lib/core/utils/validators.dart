/// Reusable `TextFormField` validators: each factory returns a
/// `String? Function(String?)`. [message] is required on purpose — validators
/// are UI-free, so the caller passes the localized copy (UI-4); there is no
/// English default to strip later. Empty input passes except for [required],
/// so presence and format validation stay independent.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');
  static final RegExp _phoneDigits = RegExp(r'^\+?[0-9]{7,15}$');
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _phoneSeparators = RegExp(r'[\s()-]');

  static String? Function(String?) required({required String message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) email({required String message}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (!_email.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) password({required String message}) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length < 8) {
        return message;
      }
      if (!_hasUppercase.hasMatch(text)) {
        return message;
      }
      if (!_hasLowercase.hasMatch(text)) {
        return message;
      }
      if (!_hasDigit.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) confirmPassword(
    String original, {
    required String message,
  }) {
    return (value) {
      if ((value ?? '') != original) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) phone({required String message}) {
    return (value) {
      final text = (value ?? '').replaceAll(_phoneSeparators, '');
      if (text.isEmpty) return null;
      if (!_phoneDigits.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) minLength(
    int length, {
    required String message,
  }) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length < length) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(
    int length, {
    required String message,
  }) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length > length) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) numeric({required String message}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (!_digitsOnly.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  /// Chains [validators] in order and returns the first failure, or `null`
  /// when they all pass.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
