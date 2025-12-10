import 'package:dio/dio.dart';

class NetworkException implements Exception {
  const NetworkException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

NetworkException mapDioError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final msg = error.message ?? 'Network error';
    return NetworkException(msg, statusCode: code);
  }
  return NetworkException(error.toString());
}
