import 'package:dio/dio.dart';

/// Interceptor that adds retry logic for failed requests
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  final int maxRetries;
  final List<Duration> retryDelays;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] as int? ?? 0;

    // Don't retry if max retries reached
    if (retryCount >= maxRetries) {
      return super.onError(err, handler);
    }

    // Only retry on specific errors
    if (!_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    // Wait before retrying
    final delay = retryDelays[retryCount.clamp(0, retryDelays.length - 1)];
    await Future.delayed(delay);

    // Update retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      // Retry the request
      final response = await Dio().fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return super.onError(e, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry on connection timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      return true;
    }

    // Don't retry on 4xx client errors (bad request, auth, etc.)
    return false;
  }
}
