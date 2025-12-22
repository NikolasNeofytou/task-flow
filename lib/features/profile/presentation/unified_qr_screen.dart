import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/team_service.dart';
import '../../../core/widgets/branded_qr_code.dart';

/// Unified QR Screen with Send/Receive toggle
class UnifiedQRScreen extends ConsumerStatefulWidget {
  const UnifiedQRScreen({super.key});

  @override
  ConsumerState<UnifiedQRScreen> createState() => _UnifiedQRScreenState();
}

class _UnifiedQRScreenState extends ConsumerState<UnifiedQRScreen>
    with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  QRCodeStyle _selectedStyle = QRCodeStyle.branded;
  bool _isExporting = false;
  bool _isSendMode = true; // true = Send, false = Receive
  
  // Scanner state
  MobileScannerController? _scannerController;
  bool _hasScanned = false;
  bool _isFlashOn = false;

  // Demo data
  final String _demoName = 'John Doe';
  final String _demoEmail = 'john.doe@taskflow.com';
  final String _demoUserId = '12345';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSendMode = !_isSendMode;
      if (!_isSendMode) {
        // Entering receive mode - initialize scanner
        _initializeScanner();
      } else {
        // Entering send mode - dispose scanner
        _disposeScanner();
      }
    });
    _animationController.reset();
    _animationController.forward();
    HapticsService().trigger(HapticFeedbackType.medium);
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: _isFlashOn,
    );
    _hasScanned = false;
  }

  void _disposeScanner() {
    _scannerController?.dispose();
    _scannerController = null;
    _hasScanned = false;
    _isFlashOn = false;
  }

  @override
  Widget build(BuildContext context) {
    final qrData = 'taskflow://user/$_demoUserId/$_demoEmail/$_demoName';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSendMode ? 'Share QR Code' : 'Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle Button
          _buildToggleButton(),
          
          // Content Area
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _isSendMode
                  ? _buildSendMode(qrData)
                  : _buildReceiveMode(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleOption(
              label: 'Send',
              icon: Icons.qr_code_2,
              isSelected: _isSendMode,
              onTap: () {
                if (!_isSendMode) _toggleMode();
              },
            ),
          ),
          Expanded(
            child: _buildToggleOption(
              label: 'Receive',
              icon: Icons.qr_code_scanner,
              isSelected: !_isSendMode,
              onTap: () {
                if (_isSendMode) _toggleMode();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.neutral,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.neutral,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendMode(String qrData) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Instructions
        Card(
          color: AppColors.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.share, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Share your QR code for others to scan and connect with you',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // QR Code Card
        Center(
          child: Screenshot(
            controller: _screenshotController,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                color: _selectedStyle.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      // Profile info
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            _selectedStyle.foregroundColor.withOpacity(0.1),
                        child: Text(
                          _demoName.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _selectedStyle.foregroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _demoName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedStyle.foregroundColor,
                                ),
                      ),
                      Text(
                        _demoEmail,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedStyle.foregroundColor
                                      .withOpacity(0.7),
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // QR Code
                      BrandedQRCode(
                        data: qrData,
                        size: 250,
                        backgroundColor: _selectedStyle.backgroundColor,
                        foregroundColor: _selectedStyle.foregroundColor,
                        showLogo: true,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Scan label
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: _selectedStyle.foregroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                        ),
                        child: Text(
                          'Scan to connect',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedStyle.foregroundColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Style Selector
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Customize Style',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: QRCodeStyle.presets.length,
                    itemBuilder: (context, index) {
                      final style = QRCodeStyle.presets[index];
                      final isSelected = _selectedStyle == style;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStyle = style);
                              HapticsService().trigger(HapticFeedbackType.light);
                            },
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Container(
                              width: 75,
                              decoration: BoxDecoration(
                                color: style.backgroundColor,
                                borderRadius: BorderRadius.circular(AppRadii.md),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.qr_code_2,
                                    color: style.foregroundColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    style.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: style.foregroundColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Action Buttons
        FilledButton.icon(
          onPressed: _isExporting ? null : () => _shareQRCode(qrData),
          icon: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.share),
          label: Text(_isExporting ? 'Preparing...' : 'Share QR Code'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _isExporting ? null : () => _exportQRCode(qrData),
          icon: const Icon(Icons.download),
          label: const Text('Export as Image'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => _copyToClipboard(qrData),
          icon: const Icon(Icons.copy),
          label: const Text('Copy QR Data'),
        ),
      ],
    );
  }

  Widget _buildReceiveMode() {
    if (_scannerController == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Camera scanner
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleBarcode,
        ),

        // Overlay with scanning frame
        CustomPaint(
          painter: ScannerOverlayPainter(),
          child: Container(),
        ),

        // Top instruction
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),

        // Bottom instructions
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Point camera at teammate\'s QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'The code will be scanned automatically',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Flash toggle
              FloatingActionButton(
                onPressed: _toggleFlash,
                backgroundColor: Colors.black.withOpacity(0.7),
                child: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

    // Show success dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('User Found!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData['displayName'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userData['email'] as String,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text('Do you want to add this person to your team?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _hasScanned = false;
              });
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Add teammate logic
              await TeamService().addTeammate(
                userId: userData['userId'] as String,
                email: userData['email'] as String,
                displayName: userData['displayName'] as String,
              );

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${userData['displayName']} added to your team!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Switch back to send mode
              _toggleMode();
            },
            child: const Text('Add to Team'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _scannerController?.toggleTorch();
    HapticsService().trigger(HapticFeedbackType.light);
  }

  Future<void> _shareQRCode(String qrData) async {
    setState(() => _isExporting = true);
    HapticsService().trigger(HapticFeedbackType.light);

    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        throw Exception('Failed to capture QR code');
      }

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Scan my QR code to connect on TaskFlow!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code shared successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportQRCode(String qrData) async {
    setState(() => _isExporting = true);
    HapticsService().trigger(HapticFeedbackType.light);

    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        throw Exception('Failed to capture QR code');
      }

      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/taskflow_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code saved to:\n${imageFile.path}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _copyToClipboard(String qrData) async {
    await Clipboard.setData(ClipboardData(text: qrData));
    HapticsService().trigger(HapticFeedbackType.light);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR data copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isSendMode ? 'Send QR Code' : 'Receive QR Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSendMode) ...[
                const Text(
                  'Share your personal QR code for others to scan and connect with you.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Features:'),
                const SizedBox(height: 8),
                _buildInfoItem('🎨', 'Customize with 6 color themes'),
                _buildInfoItem('📱', 'Share via any app'),
                _buildInfoItem('💾', 'Export as image file'),
                _buildInfoItem('📋', 'Copy data to clipboard'),
              ] else ...[
                const Text(
                  'Scan someone else\'s QR code to quickly add them to your team.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('You can:'),
                const SizedBox(height: 8),
                _buildInfoItem('📷', 'Use your camera to scan'),
                _buildInfoItem('🖼️', 'Import QR from gallery'),
                _buildInfoItem('⚡', 'Instant connection'),
                _buildInfoItem('🔒', 'Secure identification'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Custom painter for the scanner overlay with semi-transparent background
/// and transparent scanning area
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Semi-transparent overlay
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Create path for the overlay with hole in the middle
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(20),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final double bracketLength = 30;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top),
      Offset(left + scanAreaSize, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - bracketLength),
      Offset(left, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + bracketLength, top + scanAreaSize),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - bracketLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
