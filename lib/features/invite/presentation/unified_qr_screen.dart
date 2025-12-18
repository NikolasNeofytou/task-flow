import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/team_service.dart';
import '../../../core/services/qr_generation_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/providers/qr_providers.dart';
import '../../../theme/tokens.dart';

enum QRMode {
  show, // Show my QR code (sender)
  scan, // Scan QR code (receiver)
}

class UnifiedQRScreen extends ConsumerStatefulWidget {
  const UnifiedQRScreen({super.key});

  @override
  ConsumerState<UnifiedQRScreen> createState() => _UnifiedQRScreenState();
}

class _UnifiedQRScreenState extends ConsumerState<UnifiedQRScreen>
    with SingleTickerProviderStateMixin {
  QRMode _currentMode = QRMode.show;
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  String? _scannedData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() async {
    final haptics = HapticsService();
    final audio = AudioService();
    await haptics.trigger(HapticFeedbackType.medium);
    await audio.play(SoundEffect.tap);

    setState(() {
      _currentMode = _currentMode == QRMode.show ? QRMode.scan : QRMode.show;
      _scannedData = null;
      _isProcessing = false;
    });

    _animationController.reset();
    _animationController.forward();

    if (_currentMode == QRMode.scan) {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    } else {
      _scannerController?.dispose();
      _scannerController = null;
    }
  }

  Future<void> _handleQRCodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _scannedData = code;
    });

    final haptics = HapticsService();
    final audio = AudioService();
    await haptics.trigger(HapticFeedbackType.success);
    await audio.play(SoundEffect.success);

    // Parse the deep link
    if (code.startsWith('taskflow://user/')) {
      final uri = Uri.parse(code);
      final userId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
      final email = uri.queryParameters['email'];
      final displayName = uri.queryParameters['displayName'];

      if (userId != null && email != null && displayName != null) {
        _showAddTeammateDialog(userId, email, displayName);
      } else {
        _showError('Invalid QR code format');
      }
    } else {
      _showError('Not a TaskFlow invite code');
    }
  }

  void _showAddTeammateDialog(String userId, String email, String displayName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Teammate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add $displayName to your team?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = false;
                _scannedData = null;
              });
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _addTeammate(userId, email, displayName);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTeammate(
      String userId, String email, String displayName) async {
    try {
      final teamService = ref.read(teamServiceProvider);
      await teamService.addTeammate(
        userId: userId,
        email: email,
        displayName: displayName,
      );

      if (mounted) {
        final haptics = HapticsService();
        final audio = AudioService();
        await haptics.trigger(HapticFeedbackType.success);
        await audio.play(SoundEffect.success);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName added to your team!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Wait a bit before allowing next scan
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isProcessing = false;
          _scannedData = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to add teammate: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    final haptics = HapticsService();
    final audio = AudioService();
    haptics.trigger(HapticFeedbackType.error);
    audio.play(SoundEffect.error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isProcessing = false;
      _scannedData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMode == QRMode.show ? 'My QR Code' : 'Scan QR Code'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _currentMode == QRMode.show
              ? _buildShowQRMode(theme, colorScheme)
              : _buildScanMode(theme, colorScheme),
        ),
      ),
      floatingActionButton: _buildToggleButton(colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildShowQRMode(ThemeData theme, ColorScheme colorScheme) {
    // Generate deep link for user profile
    // TODO: Get actual user data from auth provider
    final userId = 'user123';
    final email = 'user@example.com';
    final displayName = 'John Doe';
    final qrData = 'taskflow://user/$userId?email=${Uri.encodeComponent(email)}&displayName=${Uri.encodeComponent(displayName)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          
          // Header
          Icon(
            Icons.qr_code_2_rounded,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Share Your QR Code',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Let others scan this code to add you to their team',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // QR Code Card
          Hero(
            tag: 'qr-code',
            child: Card(
              elevation: 8,
              shadowColor: colorScheme.primary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.xl),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 240,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: colorScheme.primary,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'John Doe',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: qrData));
                    final haptics = HapticsService();
                    final audio = AudioService();
                    await haptics.trigger(HapticFeedbackType.light);
                    await audio.play(SoundEffect.tap);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Link'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final haptics = HapticsService();
                    final audio = AudioService();
                    await haptics.trigger(HapticFeedbackType.light);
                    await audio.play(SoundEffect.tap);
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildScanMode(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Camera Preview
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleQRCodeDetected,
                ),

              // Overlay
              CustomPaint(
                painter: ScannerOverlayPainter(
                  borderColor: _isProcessing
                      ? colorScheme.primary
                      : Colors.white,
                  borderWidth: 4,
                  borderLength: 40,
                  cutOutSize: 280,
                ),
                child: Container(),
              ),

              // Instructions
              Positioned(
                top: AppSpacing.xl,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Card(
                  color: colorScheme.surface.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _isProcessing
                                ? 'Processing...'
                                : 'Position the QR code within the frame',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Processing Indicator
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),

        // Bottom Instructions
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          color: colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tip: Hold your device steady',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: FloatingActionButton.extended(
        onPressed: _toggleMode,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: Icon(
          _currentMode == QRMode.show
              ? Icons.qr_code_scanner
              : Icons.qr_code_2,
        ),
        label: Text(
          _currentMode == QRMode.show
              ? 'Switch to Scan Mode'
              : 'Switch to Show Mode',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double cutOutSize;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final cutOutPath = Path()..addRRect(RRect.fromRectAndRadius(
      cutOutRect,
      const Radius.circular(AppRadii.lg),
    ));

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutOutPath),
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left + borderLength, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right - borderLength, cutOutRect.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top + borderLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left + borderLength, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left, cutOutRect.bottom - borderLength),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom),
      Offset(cutOutRect.right - borderLength, cutOutRect.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Provider
final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});
