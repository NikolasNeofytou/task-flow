import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple test screen to navigate to all new QR features
class QRTestingScreen extends StatelessWidget {
  const QRTestingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Testing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Test All QR Code Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Start with the Demo QR Screen first - it works immediately without any setup!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context,
            title: '⭐ Demo QR Screen (Start Here!)',
            subtitle: 'Interactive demo with all features - works immediately',
            icon: Icons.play_circle_filled,
            color: Colors.orange,
            onTap: () => context.push('/profile/qr/demo'),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context,
            title: 'Enhanced Personal QR',
            subtitle: 'Test custom QR styles, sharing, and export',
            icon: Icons.qr_code_2,
            onTap: () => context.push('/profile/qr/enhanced'),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context,
            title: 'QR Management (Project)',
            subtitle: 'Test invite creation, expiration, and revocation',
            icon: Icons.admin_panel_settings,
            onTap: () => context.push('/projects/1/qr/manage'),
          ),
          const SizedBox(height: 12),
          _buildTestCard(
            context,
            title: 'QR Analytics Dashboard',
            subtitle: 'View usage statistics and analytics',
            icon: Icons.analytics,
            onTap: () => context.push('/profile/qr/analytics'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Features to Test:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildFeatureItem('✓ Custom QR code styles (6 color themes)'),
          _buildFeatureItem('✓ Share QR codes via native share sheet'),
          _buildFeatureItem('✓ Export QR codes as images'),
          _buildFeatureItem('✓ Create invites with expiration'),
          _buildFeatureItem('✓ Single-use and limited-use invites'),
          _buildFeatureItem('✓ Revoke active invites'),
          _buildFeatureItem('✓ View active/expired/revoked invites'),
          _buildFeatureItem('✓ Track QR analytics (scans, shares, etc)'),
          _buildFeatureItem('✓ View popular QRs and share methods'),
          _buildFeatureItem('✓ Offline QR caching'),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: color ?? Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
