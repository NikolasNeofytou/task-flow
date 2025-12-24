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
import '../providers/profile_provider.dart';

/// Enhanced Personal QR Screen with customization and sharing
class EnhancedPersonalQRScreen extends ConsumerStatefulWidget {
  const EnhancedPersonalQRScreen({super.key});

  @override
  ConsumerState<EnhancedPersonalQRScreen> createState() => _EnhancedPersonalQRScreenState();
}

class _EnhancedPersonalQRScreenState extends ConsumerState<EnhancedPersonalQRScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  QRCodeStyle _selectedStyle = QRCodeStyle.branded;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final qrData = 'taskflow://user/${profile.id}/${profile.email}/${profile.displayName}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _showStylePicker(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          // Header
          Text(
            'Share Your Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Let others scan this QR code to add you to their team',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // QR Code Card with Screenshot capability
          Screenshot(
            controller: _screenshotController,
            child: Container(
              color: _selectedStyle.backgroundColor,
              child: Card(
                elevation: 8,
                color: _selectedStyle.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Profile info
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: _selectedStyle.foregroundColor.withOpacity(0.1),
                        child: Text(
                          profile.displayName.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _selectedStyle.foregroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        profile.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _selectedStyle.foregroundColor,
                            ),
                      ),
                      Text(
                        profile.email,
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
                      const SizedBox(height: AppSpacing.lg),

                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: profile.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              profile.statusIcon,
                              size: 16,
                              color: profile.statusColor,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              profile.statusName,
                              style: TextStyle(
                                color: profile.statusColor,
                                fontWeight: FontWeight.w600,
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
          ),
          const SizedBox(height: AppSpacing.xl),

          // Style selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Code Style',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: QRCodeStyle.presets.length,
                      itemBuilder: (context, index) {
                        final style = QRCodeStyle.presets[index];
                        final isSelected = _selectedStyle == style;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedStyle = style);
                              HapticsService().trigger(HapticFeedbackType.light);
                            },
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: style.backgroundColor,
                                borderRadius: BorderRadius.circular(AppRadii.md),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    color: style.foregroundColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    style.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: style.foregroundColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
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
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _copyInviteLink(qrData),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Invite Link'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : () => _exportQRCode(),
            icon: const Icon(Icons.download),
            label: const Text('Save as Image'),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Instructions
          Card(
            color: AppColors.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'How it works',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _InstructionItem(
                    number: '1',
                    text: 'Choose your favorite QR code style',
                  ),
                  const _InstructionItem(
                    number: '2',
                    text: 'Share via messaging apps or save as image',
                  ),
                  const _InstructionItem(
                    number: '3',
                    text: 'Teammates scan and you\'re instantly connected!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareQRCode(String qrData) async {
    setState(() => _isExporting = true);
    
    try {
      await HapticsService().trigger(HapticFeedbackType.medium);

      // Capture the QR code as an image
      final imageBytes = await _screenshotController.capture();
      
      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/my_qr_code.png').create();
      await file.writeAsBytes(imageBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan my QR code to add me to your TaskFlow team!',
      );

      if (mounted) {
        await HapticsService().trigger(HapticFeedbackType.success);
      }
    } catch (e) {
      debugPrint('Error sharing QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share QR code: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportQRCode() async {
    setState(() => _isExporting = true);
    
    try {
      await HapticsService().trigger(HapticFeedbackType.medium);

      // Capture the QR code as an image
      final imageBytes = await _screenshotController.capture();
      
      if (imageBytes == null) {
        throw Exception('Failed to capture QR code');
      }

      // Save to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${appDir.path}/qr_code_$timestamp.png').create();
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        await HapticsService().trigger(HapticFeedbackType.success);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code saved to ${file.path}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error exporting QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export QR code: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _copyInviteLink(String qrData) async {
    await HapticsService().trigger(HapticFeedbackType.light);
    await Clipboard.setData(ClipboardData(text: qrData));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite link copied to clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showStylePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose QR Code Style',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: QRCodeStyle.presets.map((style) {
                return InkWell(
                  onTap: () {
                    setState(() => _selectedStyle = style);
                    HapticsService().trigger(HapticFeedbackType.light);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: style.backgroundColor,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: _selectedStyle == style
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: _selectedStyle == style ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          color: style.foregroundColor,
                          size: 40,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          style.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: style.foregroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Text('About QR Codes'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your personal QR code contains your profile information and allows teammates to quickly add you to projects.',
              ),
              SizedBox(height: 12),
              Text(
                '✓ Unique to you\n'
                '✓ Safe to share\n'
                '✓ No sensitive data\n'
                '✓ Works offline',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Customize the style to match your personality or brand!',
                style: TextStyle(fontStyle: FontStyle.italic),
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
}

class _InstructionItem extends StatelessWidget {
  const _InstructionItem({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
