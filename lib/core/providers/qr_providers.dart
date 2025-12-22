import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/qr_scan_service.dart';
import '../services/qr_generation_service.dart';
import '../services/qr_cache_service.dart';
import '../services/qr_analytics_service.dart';

/// Provider for QR scanning service
final qrScanServiceProvider = Provider<QRScanService>((ref) {
  final service = QRScanService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for QR generation service
final qrGenerationServiceProvider = Provider<QRGenerationService>((ref) {
  return QRGenerationService();
});

/// Provider for QR cache service
/// Handles offline caching of QR codes and scan queue
final qrCacheServiceProvider = Provider<QRCacheService>((ref) {
  return QRCacheService();
});

/// Provider for QR analytics service
/// Tracks and analyzes QR code usage statistics
final qrAnalyticsServiceProvider = Provider<QRAnalyticsService>((ref) {
  return QRAnalyticsService();
});
