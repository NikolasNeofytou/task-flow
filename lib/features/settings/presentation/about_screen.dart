import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../theme/tokens.dart';
import '../../../core/network/api_config.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About TaskFlow'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // App Icon & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'TaskFlow',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Team Collaboration Made Simple',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Version Info
          _buildInfoCard(
            context,
            title: 'Version Information',
            items: [
              _InfoItem(
                'Version',
                _packageInfo?.version ?? ApiConfig.appVersion,
              ),
              _InfoItem(
                'Build Number',
                _packageInfo?.buildNumber ?? ApiConfig.buildNumber,
              ),
              _InfoItem(
                'Package Name',
                _packageInfo?.packageName ?? 'com.taskflow.app',
              ),
              _InfoItem(
                'Environment',
                ApiConfig.environment.name.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Features
          _buildInfoCard(
            context,
            title: 'Features',
            items: const [
              _InfoItem('✓', 'Task Management'),
              _InfoItem('✓', 'Real-time Chat'),
              _InfoItem('✓', 'Audio Calls'),
              _InfoItem('✓', 'QR Code Invites'),
              _InfoItem('✓', 'Push Notifications'),
              _InfoItem('✓', 'Offline Support'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Links
          _buildInfoCard(
            context,
            title: 'Information',
            items: [
              _InfoItem(
                'Privacy Policy',
                'View our privacy policy',
                onTap: () => Navigator.pushNamed(context, '/privacy'),
              ),
              _InfoItem(
                'Terms of Service',
                'View terms of service',
                onTap: () => Navigator.pushNamed(context, '/terms'),
              ),
              _InfoItem(
                'Open Source Licenses',
                'View third-party licenses',
                onTap: () => Navigator.pushNamed(context, '/licenses'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Credits
          _buildInfoCard(
            context,
            title: 'Credits',
            items: const [
              _InfoItem('Developed by', 'TaskFlow Team'),
              _InfoItem('University Project', 'HCI Course 2024-2025'),
              _InfoItem('Framework', 'Flutter & Dart'),
              _InfoItem('Backend', 'Node.js & Express'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Copyright
          Center(
            child: Text(
              '© 2024-2025 TaskFlow\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<_InfoItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map((item) => _buildInfoRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, _InfoItem item) {
    final widget = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );

    if (item.onTap != null) {
      return InkWell(
        onTap: item.onTap,
        child: widget,
      );
    }

    return widget;
  }
}

class _InfoItem {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoItem(this.label, this.value, {this.onTap});
}
