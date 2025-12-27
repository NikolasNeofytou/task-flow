import 'package:dio/dio.dart';
import 'app_exception.dart';

/// Convert Dio errors to AppException
AppException handleDioError(dynamic error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timed out. Please check your connection and try again.',
          cause: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'Unable to connect to server. Please check your internet connection.',
          cause: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['error'] ?? error.response?.data?['message'];

        if (statusCode == 401) {
          return AuthException(
            message ?? 'Session expired. Please login again.',
            cause: error,
          );
        } else if (statusCode == 403) {
          return AuthException(
            message ?? 'You don\'t have permission to perform this action.',
            cause: error,
          );
        } else if (statusCode == 404) {
          return NotFoundException(
            message ?? 'The requested resource was not found.',
            cause: error,
          );
        } else if (statusCode == 422) {
          return ValidationException(
            message ?? 'Invalid data provided.',
            cause: error,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ApiException(
            message ?? 'Server error. Please try again later.',
            statusCode: statusCode,
            cause: error,
          );
        }

        return ApiException(
          message ?? 'An error occurred. Please try again.',
          statusCode: statusCode,
          cause: error,
        );

      case DioExceptionType.cancel:
        return UnknownException('Request was cancelled.', cause: error);

      case DioExceptionType.unknown:
        return NetworkException(
          'Network error. Please check your connection.',
          cause: error,
        );

      default:
        return UnknownException('An unexpected error occurred.', cause: error);
    }
  }

  if (error is AppException) {
    return error;
  }

  return UnknownException(
    error.toString(),
    cause: error,
  );
}

/// Get user-friendly error message
String getErrorMessage(dynamic error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is DioException) {
    return handleDioError(error).message;
  }
  return 'An unexpected error occurred. Please try again.';
}
