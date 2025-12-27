/// Base exception class for all app errors
abstract class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final dynamic cause;

  @override
  String toString() => message;
}

/// Network-related errors
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// API errors (4xx, 5xx responses)
class ApiException extends AppException {
  const ApiException(
    super.message, {
    this.statusCode,
    super.cause,
  });

  final int? statusCode;
}

/// Authentication/Authorization errors
class AuthException extends AppException {
  const AuthException(super.message, {super.cause});
}

/// Validation errors
class ValidationException extends AppException {
  const ValidationException(super.message, {this.field, super.cause});

  final String? field;
}

/// Data not found errors
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});
}

/// Timeout errors
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.cause});
}

/// Offline errors
class OfflineException extends AppException {
  const OfflineException(super.message, {super.cause});
}

/// Cache errors
class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

/// Unknown/unexpected errors
class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
}
