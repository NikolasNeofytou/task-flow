import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity service to monitor online/offline status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  
  bool _isOnline = true;
  
  /// Current online status
  bool get isOnline => _isOnline;
  
  /// Stream of connectivity status changes
  Stream<bool> get statusStream => _statusController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial status
    _isOnline = await checkConnectivity();
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((result) => result != ConnectivityResult.none);
      
      if (wasOnline != _isOnline) {
        _statusController.add(_isOnline);
      }
    });
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Riverpod provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for current online status
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});
