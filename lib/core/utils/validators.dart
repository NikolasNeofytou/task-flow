/// Input validation utilities
class Validators {
  /// Validate email address
  static bool email(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  static bool password(String password) {
    // At least 8 characters, contains letter and number
    return password.length >= 8 &&
        password.contains(RegExp(r'[a-zA-Z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  /// Validate phone number
  static bool phone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Validate URL
  static bool url(String url) {
    final urlRegex = RegExp(r'^https?:\/\/.+\..+');
    return urlRegex.hasMatch(url.trim());
  }

  /// Validate that string is not empty
  static bool required(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool minLength(String value, int min) {
    return value.length >= min;
  }

  /// Validate maximum length
  static bool maxLength(String value, int max) {
    return value.length <= max;
  }

  /// Validate numeric value
  static bool numeric(String value) {
    return double.tryParse(value) != null;
  }

  /// Validate positive number
  static bool positiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number > 0;
  }
}

/// String utility functions
class StringUtils {
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Convert to title case
  static String titleCase(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate initials from name
  static String initials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// Check if string is empty or null
  static bool isEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Remove extra whitespace
  static String clean(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
