import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_config.dart';
import '../../../core/providers/feedback_providers.dart';
import '../../../core/services/feedback_service.dart';

/// Screen that processes invite deep links and joins projects
class InviteAcceptScreen extends ConsumerStatefulWidget {
  final int projectId;
  final String token;

  const InviteAcceptScreen({
    super.key,
    required this.projectId,
    required this.token,
  });

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  bool _isProcessing = true;
  String? _errorMessage;
  String? _projectName;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _processInvite();
  }

  Future<void> _processInvite() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

      // Step 1: Validate invite token
      final validateResponse = await dio.get('/invite/${widget.token}');

      if (validateResponse.statusCode != 200) {
        throw Exception('Invalid invite');
      }

      final data = validateResponse.data;
      final projectName = data['projectName'] ?? 'Unknown Project';

      setState(() {
        _projectName = projectName;
      });

      // Step 2: Accept invite
      final acceptResponse = await dio.post(
        '/invite/${widget.token}/accept',
        data: {'userId': 'current-user'}, // TODO: Use real user ID from auth
      );

      if (acceptResponse.statusCode != 200) {
        throw Exception('Failed to accept invite');
      }

      // Success!
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.success);

      setState(() {
        _isProcessing = false;
        _success = true;
      });

      // Auto-navigate to project after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/projects/${widget.projectId}',
          );
        }
      });
    } on DioException catch (e) {
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.error);

      String message = 'Failed to process invite';
      if (e.response?.statusCode == 404) {
        message = 'Invalid or expired invite';
      } else if (e.response?.statusCode == 409) {
        message = 'This invite has already been used';
      } else if (e.response?.statusCode == 410) {
        message = 'This invite has expired';
      }

      setState(() {
        _isProcessing = false;
        _errorMessage = message;
      });
    } catch (e) {
      await ref.read(feedbackServiceProvider).trigger(FeedbackType.error);

      setState(() {
        _isProcessing = false;
        _errorMessage = 'An unexpected error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Project'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Processing invite...',
            style: theme.textTheme.titleMedium,
          ),
          if (_projectName != null) ...[
            const SizedBox(height: 8),
            Text(
              'Joining $_projectName',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ],
      );
    }

    if (_success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Successfully joined!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _projectName ?? 'Project',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Redirecting to project...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

    // Error state
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Unable to join project',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Unknown error',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Go Back'),
        ),
      ],
    );
  }
}
