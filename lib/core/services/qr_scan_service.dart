import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Service for scanning QR codes using device camera
class QRScanService {
  MobileScannerController? _controller;
  bool _isScanning = false;
  bool _isInitialized = false;

  bool get isScanning => _isScanning;
  bool get isInitialized => _isInitialized;

  /// Request camera permission
  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Initialize QR scanner
  Future<MobileScannerController> initializeController() async {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _isInitialized = true;
    return _controller!;
  }

  /// Get controller
  MobileScannerController? get controller => _controller;

  /// Start scanning
  Future<void> startScanning() async {
    if (_controller == null) {
      throw Exception('QR scanner not initialized');
    }
    await _controller!.start();
    _isScanning = true;
  }

  /// Pause scanning
  Future<void> pauseScanning() async {
    if (_controller == null) return;
    await _controller!.stop();
    _isScanning = false;
  }

  /// Stop scanning and release resources
  Future<void> stopScanning() async {
    if (_controller == null) return;
    await _controller!.stop();
    _isScanning = false;
  }

  /// Toggle flash (torch)
  Future<void> toggleFlash() async {
    if (_controller == null) return;
    await _controller!.toggleTorch();
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_controller == null) return;
    await _controller!.switchCamera();
  }

  /// Dispose controller
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isScanning = false;
    _isInitialized = false;
  }

  /// Validate scanned data is a valid invite link
  /// Expected format: taskflow://invite/{projectId}/{token}
  bool isValidInviteLink(String data) {
    if (!data.startsWith('taskflow://invite/')) {
      return false;
    }

    try {
      final uri = Uri.parse(data);
      final segments = uri.pathSegments;

      // Must have: /invite/{projectId}/{token}
      if (segments.length < 3) return false;
      if (segments[0] != 'invite') return false;

      // Project ID should be a valid integer
      final projectId = int.tryParse(segments[1]);
      if (projectId == null) return false;

      // Token should be non-empty
      final token = segments[2];
      if (token.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Parse invite link to extract project ID and token
  /// Returns null if invalid
  InviteData? parseInviteLink(String data) {
    if (!isValidInviteLink(data)) {
      return null;
    }

    try {
      final uri = Uri.parse(data);
      final segments = uri.pathSegments;

      final projectId = int.parse(segments[1]);
      final token = segments[2];

      return InviteData(
        projectId: projectId,
        token: token,
        rawUrl: data,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Data extracted from an invite QR code
class InviteData {
  final int projectId;
  final String token;
  final String rawUrl;

  InviteData({
    required this.projectId,
    required this.token,
    required this.rawUrl,
  });

  @override
  String toString() => 'InviteData(projectId: $projectId, token: $token)';
}
