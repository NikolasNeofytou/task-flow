/// Utility tests for formatters and validators
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/formatters.dart';
import 'package:taskflow/core/utils/validators.dart';

void main() {
  group('Date Formatters', () {
    test('formatDate formats correctly', () {
      // Arrange
      final date = DateTime(2025, 1, 15, 14, 30);

      // Act
      final result = DateFormatters.formatDate(date);

      // Assert
      expect(result, 'Jan 15, 2025');
    });

    test('formatTime formats correctly', () {
      // Arrange
      final date = DateTime(2025, 1, 15, 14, 30);

      // Act
      final result = DateFormatters.formatTime(date);

      // Assert
      expect(result, '2:30 PM');
    });

    test('formatDateTime combines date and time', () {
      // Arrange
      final date = DateTime(2025, 1, 15, 14, 30);

      // Act
      final result = DateFormatters.formatDateTime(date);

      // Assert
      expect(result, contains('Jan 15'));
      expect(result, contains('2:30 PM'));
    });

    test('formatRelativeTime shows "Just now"', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(seconds: 10));

      // Act
      final result = DateFormatters.formatRelativeTime(date);

      // Assert
      expect(result, 'Just now');
    });

    test('formatRelativeTime shows minutes ago', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(minutes: 5));

      // Act
      final result = DateFormatters.formatRelativeTime(date);

      // Assert
      expect(result, '5 minutes ago');
    });

    test('formatRelativeTime shows hours ago', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(hours: 2));

      // Act
      final result = DateFormatters.formatRelativeTime(date);

      // Assert
      expect(result, '2 hours ago');
    });

    test('formatRelativeTime shows days ago', () {
      // Arrange
      final date = DateTime.now().subtract(const Duration(days: 3));

      // Act
      final result = DateFormatters.formatRelativeTime(date);

      // Assert
      expect(result, '3 days ago');
    });
  });

  group('Email Validators', () {
    test('valid email passes validation', () {
      // Act & Assert
      expect(Validators.isValidEmail('test@example.com'), true);
      expect(Validators.isValidEmail('user.name@domain.co.uk'), true);
      expect(Validators.isValidEmail('user+tag@example.com'), true);
    });

    test('invalid email fails validation', () {
      // Act & Assert
      expect(Validators.isValidEmail(''), false);
      expect(Validators.isValidEmail('notanemail'), false);
      expect(Validators.isValidEmail('@example.com'), false);
      expect(Validators.isValidEmail('user@'), false);
      expect(Validators.isValidEmail('user @example.com'), false);
    });
  });

  group('Password Validators', () {
    test('valid password passes validation', () {
      // Act & Assert
      expect(Validators.isValidPassword('password123'), true);
      expect(Validators.isValidPassword('MyP@ssw0rd'), true);
      expect(Validators.isValidPassword('12345678'), true);
    });

    test('short password fails validation', () {
      // Act & Assert
      expect(Validators.isValidPassword(''), false);
      expect(Validators.isValidPassword('12345'), false);
      expect(Validators.isValidPassword('pass'), false);
    });

    test('password strength is calculated correctly', () {
      // Act & Assert
      expect(Validators.getPasswordStrength('12345678'), lessThan(50));
      expect(Validators.getPasswordStrength('Password1'), greaterThan(50));
      expect(Validators.getPasswordStrength('P@ssw0rd!'), greaterThan(75));
    });
  });

  group('String Validators', () {
    test('empty string detection works', () {
      // Act & Assert
      expect(Validators.isEmpty(''), true);
      expect(Validators.isEmpty('   '), true);
      expect(Validators.isEmpty(null), true);
      expect(Validators.isEmpty('text'), false);
    });

    test('length validation works', () {
      // Act & Assert
      expect(Validators.hasMinLength('test', 3), true);
      expect(Validators.hasMinLength('test', 5), false);
      expect(Validators.hasMaxLength('test', 5), true);
      expect(Validators.hasMaxLength('test', 3), false);
    });

    test('URL validation works', () {
      // Act & Assert
      expect(Validators.isValidUrl('https://example.com'), true);
      expect(Validators.isValidUrl('http://test.org'), true);
      expect(Validators.isValidUrl('not a url'), false);
      expect(Validators.isValidUrl(''), false);
    });
  });

  group('Number Formatters', () {
    test('formats numbers with commas', () {
      // Act & Assert
      expect(NumberFormatters.formatWithCommas(1000), '1,000');
      expect(NumberFormatters.formatWithCommas(1234567), '1,234,567');
      expect(NumberFormatters.formatWithCommas(100), '100');
    });

    test('formats currency correctly', () {
      // Act & Assert
      expect(NumberFormatters.formatCurrency(1234.56), '\$1,234.56');
      expect(NumberFormatters.formatCurrency(100), '\$100.00');
      expect(NumberFormatters.formatCurrency(0.99), '\$0.99');
    });

    test('formats percentages correctly', () {
      // Act & Assert
      expect(NumberFormatters.formatPercentage(0.5), '50%');
      expect(NumberFormatters.formatPercentage(0.75), '75%');
      expect(NumberFormatters.formatPercentage(1), '100%');
    });
  });

  group('String Utilities', () {
    test('capitalizes first letter', () {
      // Act & Assert
      expect(StringUtils.capitalize('hello'), 'Hello');
      expect(StringUtils.capitalize('world'), 'World');
      expect(StringUtils.capitalize(''), '');
    });

    test('truncates long text', () {
      // Arrange
      const longText = 'This is a very long text that needs truncation';

      // Act & Assert
      expect(
        StringUtils.truncate(longText, 20),
        'This is a very long...',
      );
      expect(StringUtils.truncate('Short', 20), 'Short');
    });

    test('extracts initials', () {
      // Act & Assert
      expect(StringUtils.getInitials('John Doe'), 'JD');
      expect(StringUtils.getInitials('Alice'), 'A');
      expect(StringUtils.getInitials('Bob Smith Jr'), 'BS');
    });
  });
}
