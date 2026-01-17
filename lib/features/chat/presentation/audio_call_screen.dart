import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../models/audio_call_models.dart';
import '../providers/audio_call_provider.dart';

/// Full screen audio call interface
class AudioCallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final String channelName;

  const AudioCallScreen({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start the call when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCall();
    });
  }

  Future<void> _initializeCall() async {
    // Mock participants for demo
    final mockParticipants = [
      const CallParticipant(
        id: 'me',
        name: 'You',
        isMe: true,
      ),
      const CallParticipant(
        id: '2',
        name: 'Alex',
      ),
      const CallParticipant(
        id: '3',
        name: 'Sarah',
      ),
      const CallParticipant(
        id: '4',
        name: 'Mike',
      ),
    ];

    await ref.read(audioCallProvider.notifier).startCall(
          channelId: widget.channelId,
          channelName: widget.channelName,
          initialParticipants: mockParticipants,
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _endCall() {
    ref.read(audioCallProvider.notifier).endCall();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(audioCallProvider);

    if (call == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(call),
            
            // Participants grid
            Expanded(
              child: _buildParticipantsGrid(call),
            ),

            // Controls
            _buildControls(call),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AudioCall call) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Text(
            call.channelName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (call.state == CallState.connecting)
                const Text(
                  'Connecting...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral,
                  ),
                )
              else ...[
                Text(
                  call.durationText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${call.participantCount} participants',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsGrid(AudioCall call) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: call.participants.length,
      itemBuilder: (context, index) {
        final participant = call.participants[index];
        return _buildParticipantCard(participant);
      },
    );
  }

  Widget _buildParticipantCard(CallParticipant participant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: participant.isSpeaking ? Colors.green : AppColors.neutral.withOpacity(0.3),
          width: participant.isSpeaking ? 3 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar with pulse animation when speaking
          Stack(
            alignment: Alignment.center,
            children: [
              if (participant.isSpeaking)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100 + (_pulseController.value * 20),
                      height: 100 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.2 * (1 - _pulseController.value)),
                      ),
                    );
                  },
                ),
              CircleAvatar(
                radius: 50,
                backgroundColor: participant.statusColor,
                child: Text(
                  participant.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (participant.isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            participant.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (participant.isMe)
            const Text(
              '(You)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.neutral,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(AudioCall call) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: call.isMuted ? Icons.mic_off : Icons.mic,
            label: call.isMuted ? 'Unmute' : 'Mute',
            color: call.isMuted ? Colors.red : AppColors.primary,
            onTap: () => ref.read(audioCallProvider.notifier).toggleMute(),
          ),

          // End call button
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: Colors.red,
            size: 70,
            iconSize: 32,
            onTap: _endCall,
          ),

          // Speaker button
          _buildControlButton(
            icon: call.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: call.isSpeakerOn ? 'Speaker On' : 'Speaker Off',
            color: call.isSpeakerOn ? AppColors.primary : Colors.grey,
            onTap: () => ref.read(audioCallProvider.notifier).toggleSpeaker(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 28,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral,
          ),
        ),
      ],
    );
  }
}

/// Floating audio call indicator (minimized view)
class FloatingCallIndicator extends ConsumerWidget {
  final VoidCallback onTap;

  const FloatingCallIndicator({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(audioCallProvider);

    if (call == null || !call.isActive) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: Colors.green,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.white),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        call.channelName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${call.durationText} • ${call.participantCount} participants',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.expand_less, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
