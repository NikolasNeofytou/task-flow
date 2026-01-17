import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/team_service.dart';

/// Screen for scanning teammate QR codes to add them to your team
class ScanTeammateScreen extends ConsumerStatefulWidget {
  const ScanTeammateScreen({super.key});

  @override
  ConsumerState<ScanTeammateScreen> createState() => _ScanTeammateScreenState();
}

class _ScanTeammateScreenState extends ConsumerState<ScanTeammateScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
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

    // Validate user invite link (taskflow://user/userId/email/name)
    final isValid = data.startsWith('taskflow://user/') && data.split('/').length >= 5;

    if (!isValid) {
      // Invalid QR code - show error
      await HapticsService().trigger(HapticFeedbackType.error);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid QR Code'),
          content: const Text('This QR code is not a valid user profile.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasScanned = false;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );

      return;
    }

    // Valid user QR - trigger success feedback
    await HapticsService().trigger(HapticFeedbackType.success);

    // Parse user data
    final parts = data.split('/');
    final userData = {
      'userId': parts[3],
      'email': parts.length > 4 ? Uri.decodeComponent(parts[4]) : 'Unknown',
      'displayName': parts.length > 5 ? Uri.decodeComponent(parts[5]) : 'Unknown User',
    };

    if (!mounted) return;

    // Show success dialog with user info
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Teammate Found!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to add this person to your team?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          userData['displayName']!.substring(0, 2).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['displayName']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              userData['email']!,
                              style: const TextStyle(
                                color: AppColors.neutral,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Return to profile
            },
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              // Show loading
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Add teammate via backend API
                final teamService = TeamService();
                final result = await teamService.addTeammate(
                  userId: userData['userId']!,
                  email: userData['email']!,
                  displayName: userData['displayName']!,
                );

                await HapticsService().trigger(HapticFeedbackType.success);

                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? '${userData['displayName']} added to your team!'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'View Team',
                        textColor: Colors.white,
                        onPressed: () => context.go('/projects'),
                      ),
                    ),
                  );
                  context.pop(); // Return to profile
                }
              } catch (e) {
                await HapticsService().trigger(HapticFeedbackType.error);

                if (context.mounted) {
                  Navigator.pop(context); // Close loading dialog

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 28),
                          SizedBox(width: 12),
                          Text('Error'),
                        ],
                      ),
                      content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _hasScanned = false;
                            });
                          },
                          child: const Text('Try Again'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.pop(); // Return to profile
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Add Teammate'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    await _controller?.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    await HapticsService().trigger(HapticFeedbackType.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Teammate QR'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          if (_controller != null)
            MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
            ),

          // Overlay with scanning frame
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white.withOpacity(0.9),
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Point camera at teammate\'s QR code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The code will be scanned automatically',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
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

/// Custom painter for the scanning frame overlay
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    // Draw semi-transparent overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
