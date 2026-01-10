import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Provider for connectivity status
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // Handle both single result and list of results
    if (results is List<ConnectivityResult>) {
      return results.any((result) => result != ConnectivityResult.none);
    } else {
      // Fallback for single result (older versions)
      return results != ConnectivityResult.none;
    }
  });
});

/// Provider to check if device is currently online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);
  return connectivityAsync.maybeWhen(
    data: (isConnected) => isConnected,
    orElse: () => true, // Assume online by default
  );
});
