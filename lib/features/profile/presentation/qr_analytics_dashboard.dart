import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/tokens.dart';
import '../../../core/services/qr_analytics_service.dart';
import '../../../core/services/qr_cache_service.dart';

/// Analytics dashboard for QR code usage
class QRAnalyticsDashboard extends ConsumerStatefulWidget {
  const QRAnalyticsDashboard({super.key});

  @override
  ConsumerState<QRAnalyticsDashboard> createState() => _QRAnalyticsDashboardState();
}

class _QRAnalyticsDashboardState extends ConsumerState<QRAnalyticsDashboard> {
  final _analyticsService = QRAnalyticsService();
  final _cacheService = QRCacheService();
  
  QRAnalyticsSummary? _summary;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final summary = await _analyticsService.getAnalyticsSummary();
      final cacheStats = await _cacheService.getCacheStats();
      
      setState(() {
        _summary = summary;
        _cacheStats = cacheStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalytics,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Overview Cards
                  _buildOverviewSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Activity Stats
                  _buildActivitySection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Popular QR Codes
                  _buildPopularQRsSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Share Methods
                  _buildShareMethodsSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Cache Stats
                  _buildCacheStatsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    if (_summary == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: 'Total Events',
              value: _summary!.totalEvents.toString(),
              icon: Icons.analytics,
              color: AppColors.primary,
            ),
            _buildStatCard(
              title: 'Generations',
              value: _summary!.totalGenerations.toString(),
              icon: Icons.qr_code_2,
              color: AppColors.success,
            ),
            _buildStatCard(
              title: 'Scans',
              value: _summary!.totalScans.toString(),
              icon: Icons.qr_code_scanner,
              color: AppColors.info,
            ),
            _buildStatCard(
              title: 'Shares',
              value: _summary!.totalShares.toString(),
              icon: Icons.share,
              color: AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    if (_summary == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Activity Stats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildActivityRow(
              'Total Views',
              _summary!.totalViews,
              Icons.visibility,
              AppColors.primary,
            ),
            _buildActivityRow(
              'Total Exports',
              _summary!.totalExports,
              Icons.download,
              AppColors.success,
            ),
            _buildActivityRow(
              'Scan Success Rate',
              _summary!.scanSuccessRate,
              Icons.check_circle,
              AppColors.info,
              suffix: '%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(
    String label,
    int value,
    IconData icon,
    Color color, {
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '$value$suffix',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularQRsSection() {
    if (_summary == null || _summary!.popularQRs.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Most Popular QR Codes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._summary!.popularQRs.map((qr) {
              final qrId = qr['qrId'] as String;
              final count = qr['count'] as int;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.qr_code_2, color: AppColors.primary),
                ),
                title: Text(
                  qrId.length > 20 ? '${qrId.substring(0, 20)}...' : qrId,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    '$count events',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildShareMethodsSection() {
    if (_summary == null || _summary!.shareMethods.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: AppColors.info),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Share Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._summary!.shareMethods.entries.map((entry) {
              final method = entry.key;
              final count = entry.value;
              final total = _summary!.totalShares;
              final percentage = total > 0 ? (count / total * 100).round() : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          method.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          '$count ($percentage%)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.neutral,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.neutral.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheStatsSection() {
    if (_cacheStats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: AppColors.success),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Offline Cache',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCacheRow('Total Cached', _cacheStats!['totalCached']),
            _buildCacheRow('User QRs', _cacheStats!['userQRs']),
            _buildCacheRow('Project QRs', _cacheStats!['projectQRs']),
            _buildCacheRow('Queued Scans', _cacheStats!['queuedScans']),
            _buildCacheRow('Pending', _cacheStats!['pendingScans']),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Cache'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAnalytics() async {
    try {
      final jsonData = await _analyticsService.exportAnalyticsAsJson();
      
      // In a real app, you would save this to a file or share it
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analytics exported successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove all cached QR codes and queued scans. '
          'You will need to regenerate them if you want to use them offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cacheService.clearCache();
        await _cacheService.clearScanQueue();
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cache cleared successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear cache: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
