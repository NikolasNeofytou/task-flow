import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/feedback_providers.dart';
import '../../../core/services/feedback_service.dart';
import '../../../theme/tokens.dart';

class FeedbackSettingsScreen extends ConsumerWidget {
  const FeedbackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);
    final soundEnabled = ref.watch(soundEnabledProvider);
    final volume = ref.watch(soundVolumeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haptics & Sound'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Feedback Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Control haptic vibrations and sound effects for app interactions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Haptics Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.vibration, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Haptic Feedback',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Enable Haptics'),
                  subtitle: const Text('Feel vibrations for button presses and actions'),
                  value: hapticsEnabled,
                  onChanged: (value) {
                    ref.read(hapticsEnabledProvider.notifier).state = value;
                    if (value) {
                      ref.read(feedbackServiceProvider).trigger(FeedbackType.success);
                    }
                  },
                ),
                if (hapticsEnabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Haptic Patterns',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _TestButton(
                              label: 'Light',
                              feedbackType: FeedbackType.lightTap,
                            ),
                            _TestButton(
                              label: 'Medium',
                              feedbackType: FeedbackType.mediumImpact,
                            ),
                            _TestButton(
                              label: 'Success',
                              feedbackType: FeedbackType.success,
                            ),
                            _TestButton(
                              label: 'Warning',
                              feedbackType: FeedbackType.warning,
                            ),
                            _TestButton(
                              label: 'Error',
                              feedbackType: FeedbackType.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Sound Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Sound Effects',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Enable Sounds'),
                  subtitle: const Text('Play sound effects for actions'),
                  value: soundEnabled,
                  onChanged: (value) {
                    ref.read(soundEnabledProvider.notifier).state = value;
                    if (value) {
                      ref.read(feedbackServiceProvider).trigger(FeedbackType.success);
                    }
                  },
                ),
                if (soundEnabled) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Volume',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${(volume * 100).round()}%',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                        Slider(
                          value: volume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: '${(volume * 100).round()}%',
                          onChanged: (value) {
                            ref.read(soundVolumeProvider.notifier).state = value;
                          },
                          onChangeEnd: (value) {
                            ref.read(feedbackServiceProvider).trigger(FeedbackType.lightTap);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '⚠️ Note: Sound files not yet added. Haptics will still work.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Info Card
          Card(
            color: AppColors.info.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.info),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'About Feedback',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.info,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Haptic feedback helps you feel when you interact with the app. '
                    'Different patterns indicate different types of actions:\n\n'
                    '• Light: Button taps, selections\n'
                    '• Medium: Creating items, sending\n'
                    '• Success: Completed actions\n'
                    '• Warning: Validation errors\n'
                    '• Error: Failed actions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
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

class _TestButton extends ConsumerWidget {
  const _TestButton({
    required this.label,
    required this.feedbackType,
  });

  final String label;
  final FeedbackType feedbackType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        ref.read(feedbackServiceProvider).trigger(feedbackType);
      },
      child: Text(label),
    );
  }
}
