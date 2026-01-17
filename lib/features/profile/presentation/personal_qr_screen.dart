import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/haptics_service.dart';
import '../providers/profile_provider.dart';

/// Screen displaying user's personal QR code for easy team invites
class PersonalQRScreen extends ConsumerWidget {
  const PersonalQRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Generate unique user invite link
    final qrData = 'taskflow://user/${profile.id}/${profile.email}/${profile.displayName}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
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

          // QR Code Card
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Profile info
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      profile.displayName.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                      embeddedImage: null,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(50, 50),
                      ),
                    ),
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
          const SizedBox(height: AppSpacing.xl),

          // Action buttons
          FilledButton.icon(
            onPressed: () async {
              await HapticsService().trigger(HapticFeedbackType.light);
              await Clipboard.setData(ClipboardData(text: qrData));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invite link copied to clipboard!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Invite Link'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () async {
              await HapticsService().trigger(HapticFeedbackType.light);
              // Share functionality would go here
              // For now, just copy to clipboard
              await Clipboard.setData(ClipboardData(text: qrData));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share your QR code with teammates!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.share),
            label: const Text('Share QR Code'),
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
                    text: 'Show your QR code to teammates',
                  ),
                  const _InstructionItem(
                    number: '2',
                    text: 'They scan it with their camera',
                  ),
                  const _InstructionItem(
                    number: '3',
                    text: 'You\'re instantly added to their team!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About QR Codes'),
        content: const Text(
          'Your personal QR code contains your profile information and allows teammates to quickly add you to projects.\n\n'
          'The code is unique to you and can be shared safely. It does not contain any sensitive information.',
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
