import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/qr_scan_service.dart';
import '../services/qr_generation_service.dart';

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
