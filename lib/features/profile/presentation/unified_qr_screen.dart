import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/haptics_service.dart';
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
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSendMode = !_isSendMode;
    });
    _animationController.reset();
    _animationController.forward();
    HapticsService().trigger(HapticFeedbackType.medium);
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Scan QR Code',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Point your camera at a QR code to scan it',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutral,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Start Scan Button
            FilledButton.icon(
              onPressed: () => _startScanning(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Camera'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Or import from gallery
            TextButton.icon(
              onPressed: () => _importFromGallery(),
              icon: const Icon(Icons.photo_library),
              label: const Text('Import from Gallery'),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'You\'ll need to grant camera permission to scan QR codes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanning() {
    HapticsService().trigger(HapticFeedbackType.light);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera scanning will be available on mobile devices'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement actual camera scanning using mobile_scanner package
    // Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen()));
  }

  void _importFromGallery() {
    HapticsService().trigger(HapticFeedbackType.light);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery import will be available soon'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement gallery import
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
