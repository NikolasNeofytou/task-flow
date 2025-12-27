import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Last updated: December 27, 2025',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSection(
            context,
            title: '1. Information We Collect',
            content:
                'TaskFlow collects information you provide directly to us, including:\n\n'
                '• Account information (email, name, profile picture)\n'
                '• Project and task data you create\n'
                '• Messages and files you send\n'
                '• Usage data and analytics',
          ),
          _buildSection(
            context,
            title: '2. How We Use Your Information',
            content: 'We use the information we collect to:\n\n'
                '• Provide, maintain, and improve our services\n'
                '• Send you technical notices and support messages\n'
                '• Respond to your comments and questions\n'
                '• Monitor and analyze trends and usage',
          ),
          _buildSection(
            context,
            title: '3. Information Sharing',
            content:
                'We do not sell, trade, or rent your personal information to third parties. '
                'We may share your information only in the following circumstances:\n\n'
                '• With your consent\n'
                '• To comply with legal obligations\n'
                '• To protect our rights and safety',
          ),
          _buildSection(
            context,
            title: '4. Data Security',
            content:
                'We implement appropriate technical and organizational measures '
                'to protect your personal information, including:\n\n'
                '• Encryption of data in transit (HTTPS)\n'
                '• Secure storage of passwords (hashing)\n'
                '• Regular security audits\n'
                '• Access controls and authentication',
          ),
          _buildSection(
            context,
            title: '5. Data Retention',
            content:
                'We retain your personal information for as long as necessary to '
                'provide you with our services and as described in this policy. '
                'You can request deletion of your account and data at any time.',
          ),
          _buildSection(
            context,
            title: '6. Your Rights',
            content: 'You have the right to:\n\n'
                '• Access your personal information\n'
                '• Correct inaccurate data\n'
                '• Delete your account and data\n'
                '• Export your data\n'
                '• Opt-out of marketing communications',
          ),
          _buildSection(
            context,
            title: '7. Children\'s Privacy',
            content:
                'TaskFlow is not intended for children under 13 years of age. '
                'We do not knowingly collect personal information from children under 13.',
          ),
          _buildSection(
            context,
            title: '8. Changes to This Policy',
            content:
                'We may update this privacy policy from time to time. We will notify '
                'you of any changes by posting the new policy on this page and updating '
                'the "Last updated" date.',
          ),
          _buildSection(
            context,
            title: '9. Contact Us',
            content:
                'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                'Email: privacy@taskflow.app\n'
                'Website: https://taskflow.app/privacy',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
