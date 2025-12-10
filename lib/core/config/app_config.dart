import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppConfig {
  const AppConfig({
    required this.baseUrl,
    this.connectTimeoutMs = 10000,
    this.receiveTimeoutMs = 10000,
    this.useMocks = true,
  });

  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool useMocks;

  factory AppConfig.fromEnvironment() {
    const envBase =
        String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');
    const useMocksRaw =
        String.fromEnvironment('USE_MOCKS', defaultValue: 'true');
    final useMocksEnv = useMocksRaw.toLowerCase() == 'true';
    return AppConfig(baseUrl: envBase, useMocks: useMocksEnv);
  }
}

/// Swap this in one place to change environments (dev/stage/prod).
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
