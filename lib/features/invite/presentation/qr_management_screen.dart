import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/qr_generation_service.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/providers/qr_providers.dart';

/// Screen for managing QR code invites
/// Shows active invites, expired invites, and usage statistics
class QRManagementScreen extends ConsumerStatefulWidget {
  final int projectId;

  const QRManagementScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends ConsumerState<QRManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrService = ref.watch(qrGenerationServiceProvider);
    final invites = qrService.getProjectInvites(widget.projectId);
    
    final activeInvites = invites.where((i) => i.isActive).toList();
    final expiredInvites = invites.where((i) => i.isExpired).toList();
    final revokedInvites = invites.where((i) => i.isRevoked).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage QR Invites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.check_circle_outline),
              text: 'Active (${activeInvites.length})',
            ),
            Tab(
              icon: const Icon(Icons.history),
              text: 'Expired (${expiredInvites.length})',
            ),
            Tab(
              icon: const Icon(Icons.block),
              text: 'Revoked (${revokedInvites.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create New Invite',
            onPressed: () => _showCreateInviteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            tooltip: 'Clean Up Expired',
            onPressed: () => _cleanupExpired(qrService),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInviteList(activeInvites, isActive: true),
          _buildInviteList(expiredInvites, isActive: false),
          _buildInviteList(revokedInvites, isActive: false),
        ],
      ),
    );
  }

  Widget _buildInviteList(List<InviteQRData> invites, {required bool isActive}) {
    if (invites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.qr_code_2 : Icons.inbox_outlined,
              size: 80,
              color: AppColors.neutral.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isActive ? 'No active invites' : 'No invites here',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.neutral,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isActive)
              Text(
                'Create a new invite to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral.withOpacity(0.7),
                    ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: invites.length,
      itemBuilder: (context, index) {
        final invite = invites[index];
        return _buildInviteCard(invite, isActive: isActive);
      },
    );
  }

  Widget _buildInviteCard(InviteQRData invite, {required bool isActive}) {
    final qrService = ref.watch(qrGenerationServiceProvider);
    final validation = qrService.validateInvite(invite.token);
    final usageCount = validation.usageCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _showInviteDetails(invite, usageCount),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.neutral.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      isActive ? Icons.qr_code_2 : Icons.qr_code_scanner,
                      color: isActive ? AppColors.success : AppColors.neutral,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite #${invite.token.substring(0, 8)}...',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          _formatDate(invite.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(invite),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Properties
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (invite.isSingleUse)
                    _buildPropertyChip(
                      icon: Icons.looks_one,
                      label: 'Single Use',
                      color: AppColors.warning,
                    ),
                  if (invite.maxUses != null)
                    _buildPropertyChip(
                      icon: Icons.people,
                      label: 'Max: ${invite.maxUses}',
                      color: AppColors.info,
                    ),
                  _buildPropertyChip(
                    icon: Icons.check_circle,
                    label: 'Used: $usageCount',
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Expiration status
              Row(
                children: [
                  Icon(
                    invite.expiresAt != null ? Icons.schedule : Icons.all_inclusive,
                    size: 16,
                    color: AppColors.neutral,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    invite.expirationStatus,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
                  ),
                ],
              ),

              // Actions
              if (isActive) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyToken(invite.token),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQRCode(invite),
                        icon: const Icon(Icons.qr_code, size: 18),
                        label: const Text('View QR'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () => _confirmRevoke(invite),
                      icon: const Icon(Icons.block, color: AppColors.error),
                      tooltip: 'Revoke',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InviteQRData invite) {
    Color color;
    String text;
    IconData icon;

    if (invite.isRevoked) {
      color = AppColors.error;
      text = 'Revoked';
      icon = Icons.block;
    } else if (invite.isExpired) {
      color = AppColors.warning;
      text = 'Expired';
      icon = Icons.access_time;
    } else {
      color = AppColors.success;
      text = 'Active';
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateInviteDialog(BuildContext context) {
    Duration? selectedDuration;
    bool isSingleUse = false;
    int? maxUses;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Invite'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configure invite settings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Expiration
                Text(
                  'Expiration',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('1 hour'),
                      selected: selectedDuration == const Duration(hours: 1),
                      onSelected: (selected) {
                        setState(() => selectedDuration = selected ? const Duration(hours: 1) : null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('24 hours'),
                      selected: selectedDuration == const Duration(hours: 24),
                      onSelected: (selected) {
                        setState(() => selectedDuration = selected ? const Duration(hours: 24) : null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('7 days'),
                      selected: selectedDuration == const Duration(days: 7),
                      onSelected: (selected) {
                        setState(() => selectedDuration = selected ? const Duration(days: 7) : null);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Never'),
                      selected: selectedDuration == null,
                      onSelected: (selected) {
                        setState(() => selectedDuration = null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Usage limits
                SwitchListTile(
                  title: const Text('Single Use Only'),
                  value: isSingleUse,
                  onChanged: (value) {
                    setState(() {
                      isSingleUse = value;
                      if (value) maxUses = null;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _createInvite(
                  expiresIn: selectedDuration,
                  isSingleUse: isSingleUse,
                  maxUses: maxUses,
                );
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _createInvite({
    Duration? expiresIn,
    bool isSingleUse = false,
    int? maxUses,
  }) {
    final qrService = ref.read(qrGenerationServiceProvider);
    final invite = qrService.generateInvite(
      widget.projectId,
      expiresIn: expiresIn,
      isSingleUse: isSingleUse,
      maxUses: maxUses,
    );

    HapticsService().trigger(HapticFeedbackType.success);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite created successfully'),
        action: SnackBarAction(
          label: 'View QR',
          onPressed: () => _showQRCode(invite),
        ),
      ),
    );

    setState(() {}); // Refresh the list
  }

  void _copyToken(String token) {
    Clipboard.setData(ClipboardData(text: token));
    HapticsService().trigger(HapticFeedbackType.light);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copied to clipboard')),
    );
  }

  void _showQRCode(InviteQRData invite) {
    // Navigate to QR display screen or show in dialog
    // This would show the actual QR code for the invite
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 200),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Token: ${invite.token.substring(0, 12)}...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(InviteQRData invite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Invite?'),
        content: const Text(
          'This will permanently revoke this invite. Anyone with this QR code will no longer be able to use it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _revokeInvite(invite.token);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _revokeInvite(String token) {
    final qrService = ref.read(qrGenerationServiceProvider);
    qrService.revokeInvite(token);

    HapticsService().trigger(HapticFeedbackType.success);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite revoked successfully')),
    );

    setState(() {}); // Refresh the list
  }

  void _cleanupExpired(QRGenerationService qrService) {
    qrService.cleanupExpiredInvites();

    HapticsService().trigger(HapticFeedbackType.success);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expired invites cleaned up')),
    );

    setState(() {}); // Refresh the list
  }

  void _showInviteDetails(InviteQRData invite, int usageCount) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailRow('Token', invite.token),
            _buildDetailRow('Created', _formatDate(invite.createdAt)),
            if (invite.expiresAt != null)
              _buildDetailRow('Expires', _formatDate(invite.expiresAt!)),
            _buildDetailRow('Times Used', usageCount.toString()),
            if (invite.maxUses != null)
              _buildDetailRow('Max Uses', invite.maxUses.toString()),
            _buildDetailRow('Status', invite.expirationStatus),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
