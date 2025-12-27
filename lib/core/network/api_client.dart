import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../errors/error_handler.dart';
import 'auth_token_provider.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Add retry interceptor first
  dio.interceptors.add(RetryInterceptor());

  // Add logging interceptor
  dio.interceptors.add(LoggingInterceptor());

  // Add auth interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(authTokenProvider.future);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Convert to AppException
        final appError = handleDioError(error);
        // Pass along the converted error
        handler.next(DioException(
          requestOptions: error.requestOptions,
          error: appError,
          response: error.response,
          type: error.type,
        ));
      },
    ),
  );

  return dio;
});
