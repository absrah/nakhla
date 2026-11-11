/// Form checks used by text fields. Each returns an error message,
/// or null when the value is fine (that is what TextFormField expects).
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_email.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  /// Optional field: empty is fine, otherwise 8 to 15 digits (+ allowed).
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Required text field (city, district, street...).
  static String? required(String? value, String message) =>
      (value?.trim().isEmpty ?? true) ? message : null;

  /// Phone that must be filled in (for delivery), same format as [phone].
  static String? requiredPhone(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Enter a phone number' : phone(value);

  /// Optional: empty is fine, otherwise exactly 5 digits.
  static String? postalCode(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    return RegExp(r'^[0-9]{5}$').hasMatch(v) ? null : 'Postal code is 5 digits';
  }
}
