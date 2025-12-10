import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/providers/feedback_providers.dart';
import '../../../core/services/feedback_service.dart';

/// Screen for scanning QR codes to join projects
class QRScanScreen extends ConsumerStatefulWidget {
  const QRScanScreen({super.key});

  @override
  ConsumerState<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends ConsumerState<QRScanScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _handleScan(code);
  }

  Future<void> _handleScan(String data) async {
    if (_hasScanned) return;

    setState(() {
      _hasScanned = true;
    });

    // Validate invite link (taskflow://invite/projectId/token)
    final isValid = data.startsWith('taskflow://invite/') && data.split('/').length >= 5;

    if (!isValid) {
      // Invalid QR code - show error
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.error);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid QR Code'),
          content: const Text('This QR code is not a valid project invite.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );

      setState(() {
        _hasScanned = false;
      });
      return;
    }

    // Valid invite - trigger success feedback
    await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);

    // Parse invite data
    final parts = data.split('/');
    final inviteData = {
      'projectId': parts[3],
      'token': parts[4],
      'link': data,
    };

    if (!mounted) return;

    // Return invite data to caller
    Navigator.pop(context, inviteData);
  }

  Future<void> _toggleFlash() async {
    await _controller?.toggleTorch();
    await ref.read(feedbackServiceProvider).trigger(FeedbackType.lightTap);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            overlay: Container(
              decoration: ShapeDecoration(
                shape: QrScannerOverlayShape(
                  borderColor: theme.colorScheme.primary,
                  borderRadius: 16,
                  borderLength: 40,
                  borderWidth: 8,
                  cutOutSize: MediaQuery.of(context).size.width * 0.7,
                ),
              ),
            ),
          ),

          // Top bar with back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(feedbackServiceProvider).trigger(
                            FeedbackType.lightTap,
                          );
                      Navigator.pop(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Flash toggle
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flashlight_on,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan QR Code',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position the QR code within the frame',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.borderLength = 40.0,
    this.borderRadius = 10.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutSize = this.cutOutSize;
    final cutOutX = (width - cutOutSize) / 2;
    final cutOutY = (height - cutOutSize) / 2;

    return Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cutOutX, cutOutY, cutOutSize, cutOutSize),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutSize = this.cutOutSize;
    final cutOutX = (width - cutOutSize) / 2;
    final cutOutY = (height - cutOutSize) / 2;

    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutX, cutOutY + borderLength)
        ..lineTo(cutOutX, cutOutY + borderRadius)
        ..quadraticBezierTo(cutOutX, cutOutY, cutOutX + borderRadius, cutOutY)
        ..lineTo(cutOutX + borderLength, cutOutY),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutX + cutOutSize - borderLength, cutOutY)
        ..lineTo(cutOutX + cutOutSize - borderRadius, cutOutY)
        ..quadraticBezierTo(cutOutX + cutOutSize, cutOutY,
            cutOutX + cutOutSize, cutOutY + borderRadius)
        ..lineTo(cutOutX + cutOutSize, cutOutY + borderLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutX, cutOutY + cutOutSize - borderLength)
        ..lineTo(cutOutX, cutOutY + cutOutSize - borderRadius)
        ..quadraticBezierTo(cutOutX, cutOutY + cutOutSize,
            cutOutX + borderRadius, cutOutY + cutOutSize)
        ..lineTo(cutOutX + borderLength, cutOutY + cutOutSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(cutOutX + cutOutSize - borderLength, cutOutY + cutOutSize)
        ..lineTo(cutOutX + cutOutSize - borderRadius, cutOutY + cutOutSize)
        ..quadraticBezierTo(cutOutX + cutOutSize, cutOutY + cutOutSize,
            cutOutX + cutOutSize, cutOutY + cutOutSize - borderRadius)
        ..lineTo(cutOutX + cutOutSize, cutOutY + cutOutSize - borderLength),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderLength: borderLength * t,
      borderRadius: borderRadius * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
