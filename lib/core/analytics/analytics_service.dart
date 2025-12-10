import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basic analytics contract. Swap with a real implementation (e.g., Firebase) when ready.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}});
}

class ConsoleAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) async {
    // Replace with real analytics SDK calls.
    // ignore: avoid_print
    print('analytics: $name $parameters');
  }
}

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return ConsoleAnalyticsService();
});
