import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Terms of Service',
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
            title: '1. Acceptance of Terms',
            content:
                'By accessing and using TaskFlow, you accept and agree to be bound '
                'by the terms and provision of this agreement. If you do not agree '
                'to these terms, please do not use our service.',
          ),
          _buildSection(
            context,
            title: '2. Description of Service',
            content:
                'TaskFlow provides a team collaboration platform that allows users to:\n\n'
                '• Create and manage projects and tasks\n'
                '• Communicate via chat and audio calls\n'
                '• Share files and collaborate in real-time\n'
                '• Track project progress and deadlines',
          ),
          _buildSection(
            context,
            title: '3. User Accounts',
            content: 'To use TaskFlow, you must:\n\n'
                '• Create an account with accurate information\n'
                '• Maintain the security of your account\n'
                '• Be responsible for all activities under your account\n'
                '• Notify us immediately of any unauthorized access',
          ),
          _buildSection(
            context,
            title: '4. Acceptable Use',
            content: 'You agree not to:\n\n'
                '• Use the service for any illegal purpose\n'
                '• Violate any laws in your jurisdiction\n'
                '• Infringe on intellectual property rights\n'
                '• Upload malicious code or viruses\n'
                '• Harass or abuse other users\n'
                '• Spam or send unsolicited messages',
          ),
          _buildSection(
            context,
            title: '5. Content Ownership',
            content:
                'You retain ownership of all content you create and upload to TaskFlow. '
                'By using our service, you grant us a license to use, store, and display '
                'your content as necessary to provide the service.',
          ),
          _buildSection(
            context,
            title: '6. Data and Privacy',
            content:
                'Your use of TaskFlow is also governed by our Privacy Policy. '
                'Please review our Privacy Policy to understand how we collect, '
                'use, and protect your information.',
          ),
          _buildSection(
            context,
            title: '7. Termination',
            content:
                'We reserve the right to terminate or suspend your account at any time, '
                'without prior notice, for conduct that we believe violates these Terms '
                'or is harmful to other users, us, or third parties.',
          ),
          _buildSection(
            context,
            title: '8. Disclaimers',
            content:
                'TaskFlow is provided "as is" without any warranties, expressed or implied. '
                'We do not warrant that the service will be uninterrupted, secure, or error-free. '
                'You use the service at your own risk.',
          ),
          _buildSection(
            context,
            title: '9. Limitation of Liability',
            content:
                'To the maximum extent permitted by law, TaskFlow shall not be liable '
                'for any indirect, incidental, special, consequential, or punitive damages '
                'resulting from your use of or inability to use the service.',
          ),
          _buildSection(
            context,
            title: '10. Changes to Terms',
            content:
                'We reserve the right to modify these Terms at any time. We will notify '
                'users of any material changes via email or through the app. Your continued '
                'use of TaskFlow after changes constitutes acceptance of the new Terms.',
          ),
          _buildSection(
            context,
            title: '11. Contact Information',
            content:
                'For questions about these Terms, please contact us at:\n\n'
                'Email: legal@taskflow.app\n'
                'Website: https://taskflow.app/terms',
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
