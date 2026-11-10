import 'package:campusfix/core/constants/app_constants.dart';

class Validators {
  Validators._();

  static final RegExp _emailPattern =
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static bool isAluEmail(String email) {
    final value = email.trim().toLowerCase();
    return AppConstants.allowedEmailDomains
        .any((domain) => value.endsWith('@$domain'));
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your full name';
    if (text.length < 3) return 'Name is too short';
    if (text.length > 60) return 'Name is too long';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address';
    if (!isAluEmail(text)) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Enter a password';
    if (text.length < 8) return 'Use at least 8 characters';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(text);
    final hasDigit = RegExp(r'\d').hasMatch(text);
    if (!hasLetter || !hasDigit) {
      return 'Include at least one letter and one number';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if ((value ?? '').isEmpty) return 'Confirm your password';
      if (value != original()) return 'Passwords do not match';
      return null;
    };
  }

  static String? Function(String?) text({
    required String field,
    int min = 1,
    int max = 500,
  }) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return '$field is required';
      if (text.length < min) return '$field must be at least $min characters';
      if (text.length > max) return '$field must be under $max characters';
      return null;
    };
  }
}
