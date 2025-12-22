import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../../theme/tokens.dart';

/// Offline indicator banner that shows at the top of the screen
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Material(
          elevation: 4,
          color: Colors.orange.shade700,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'You\'re offline. Changes will sync when online.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final connectivity = ref.read(connectivityServiceProvider);
                      final syncService = ref.read(syncServiceProvider);
                      
                      if (await connectivity.checkConnectivity()) {
                        // Force sync
                        await syncService.syncAll();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Synced successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Still offline. Check your connection.'),
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Sync status widget showing last sync time
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncService = ref.watch(syncServiceProvider);

    return FutureBuilder<CachedData>(
      future: syncService.getCachedData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final cachedData = snapshot.data!;
        final oldestSync = cachedData.oldestSync;

        if (oldestSync == null) {
          return const Text(
            'Never synced',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          );
        }

        return Text(
          'Last synced ${_formatSyncTime(oldestSync)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final diff = now.difference(syncTime);

    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

/// Pull-to-refresh sync indicator
class SyncRefreshIndicator extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onRefresh;

  const SyncRefreshIndicator({
    super.key,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        final syncService = ref.read(syncServiceProvider);
        final result = await syncService.syncAll();

        if (context.mounted) {
          if (result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (result.isOffline) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        onRefresh?.call();
      },
      child: child,
    );
  }
}
