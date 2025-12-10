import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/deep_link_service.dart';

/// Provider for deep link service
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final service = DeepLinkService();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
