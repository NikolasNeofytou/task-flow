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

/// Demo QR Screen - Works without profile data for testing
class DemoQRScreen extends ConsumerStatefulWidget {
  const DemoQRScreen({super.key});

  @override
  ConsumerState<DemoQRScreen> createState() => _DemoQRScreenState();
}

class _DemoQRScreenState extends ConsumerState<DemoQRScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  QRCodeStyle _selectedStyle = QRCodeStyle.branded;
  bool _isExporting = false;

  // Demo data
  final String _demoName = 'John Doe';
  final String _demoEmail = 'john.doe@taskflow.com';
  final String _demoUserId = '12345';

  @override
  Widget build(BuildContext context) {
    final qrData = 'taskflow://user/$_demoUserId/$_demoEmail/$_demoName';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          // Header with instructions
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.info, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to use this QR Code:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '1. Choose a style below\n'
                          '2. Share or export the QR code\n'
                          '3. Others can scan it to add you',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
                          backgroundColor: _selectedStyle.foregroundColor.withOpacity(0.1),
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _selectedStyle.foregroundColor,
                              ),
                        ),
                        Text(
                          _demoEmail,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _selectedStyle.foregroundColor.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Branded QR Code
                        BrandedQRCode(
                          data: qrData,
                          size: 250,
                          backgroundColor: _selectedStyle.backgroundColor,
                          foregroundColor: _selectedStyle.foregroundColor,
                          showLogo: true,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // QR data preview
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

          // Style selector
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
                        'Choose Your Style',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap a style to change your QR code appearance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Style changed to ${style.name}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
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
                                      isSelected ? Icons.check_circle : Icons.qr_code_2,
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

          // Action buttons
          FilledButton.icon(
            onPressed: _isExporting ? null : () => _shareQRCode(qrData),
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
      ),
    );
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
      final imagePath = '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
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
      final imagePath = '${directory.path}/taskflow_qr_${DateTime.now().millisecondsSinceEpoch}.png';
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
        title: const Text('About QR Codes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your personal QR code allows others to quickly add you to their team.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Features:'),
              const SizedBox(height: 8),
              _buildInfoItem('🎨', 'Customize with 6 color themes'),
              _buildInfoItem('📱', 'Share via any app'),
              _buildInfoItem('💾', 'Export as image file'),
              _buildInfoItem('📋', 'Copy data to clipboard'),
              _buildInfoItem('🔒', 'Secure user identification'),
              const SizedBox(height: 16),
              Text(
                'Current data encoded:\n$_demoUserId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
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
