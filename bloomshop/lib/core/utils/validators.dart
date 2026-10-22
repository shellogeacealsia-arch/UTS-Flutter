/// Form validators. Each returns an error message or null when valid.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  static bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValidEmail(value)) return 'Enter a valid email address';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-+]'), '');
    if (!RegExp(r'^\d{9,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number (9-15 digits)';
    }
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Address is required';
    if (value.trim().length < 10) {
      return 'Please enter a complete address (min. 10 characters)';
    }
    return null;
  }

  /// Validates the whole checkout form without a widget tree.
  /// Returns a map field -> message (empty map means valid).
  static Map<String, String> checkoutErrors({
    required String name,
    required String phone,
    required String address,
  }) {
    final errors = <String, String>{};
    final nameError = fullName(name);
    final phoneError = Validators.phone(phone);
    final addressError = Validators.address(address);
    if (nameError != null) errors['name'] = nameError;
    if (phoneError != null) errors['phone'] = phoneError;
    if (addressError != null) errors['address'] = addressError;
    return errors;
  }
}
