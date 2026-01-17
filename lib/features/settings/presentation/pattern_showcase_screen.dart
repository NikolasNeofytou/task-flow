import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/pattern_widgets.dart';
import '../../../core/widgets/interaction_patterns.dart';
import '../../../core/widgets/tutorial_overlay.dart';
import '../../../theme/tokens.dart';

/// Demo screen showcasing all interaction design patterns
/// Based on Tidwell's "Designing Interfaces" book
class PatternShowcaseScreen extends ConsumerStatefulWidget {
  const PatternShowcaseScreen({super.key});

  @override
  ConsumerState<PatternShowcaseScreen> createState() =>
      _PatternShowcaseScreenState();
}

class _PatternShowcaseScreenState extends ConsumerState<PatternShowcaseScreen> {
  bool _celebrate = false;
  int _currentStep = 0;
  final List<String> _recentSearches = ['Design patterns', 'User experience'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Patterns Showcase'),
      ),
      body: CelebrationAnimation(
        celebrate: _celebrate,
        message: '🎉 Pattern Demonstrated!',
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _buildSectionTitle('1. Progressive Disclosure'),
            _buildPatternCard(
              title: 'Tutorial Overlay',
              description:
                  'Guides users step-by-step without overwhelming them',
              pattern: 'Progressive Disclosure',
              onDemo: _showTutorial,
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('2. Recognition Over Recall'),
            _buildPatternCard(
              title: 'Empty State',
              description: 'Helpful guidance when no content exists',
              pattern: 'Recognition',
              onDemo: _showEmptyState,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPatternCard(
              title: 'Search with Suggestions',
              description: 'Shows recent searches for easy access',
              pattern: 'Recognition',
              child: SearchBarWithSuggestions(
                hintText: 'Search patterns...',
                recentSearches: _recentSearches,
                onSearch: (query) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching: $query')),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('3. Perceived Performance'),
            _buildPatternCard(
              title: 'Skeleton Loaders',
              description: 'Makes loading feel faster with placeholders',
              pattern: 'Perceived Performance',
              onDemo: _showSkeletonLoader,
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('4. Direct Manipulation'),
            _buildPatternCard(
              title: 'Swipeable Item',
              description: 'Swipe right to complete, left to delete',
              pattern: 'Direct Manipulation',
              child: SwipeableListItem(
                onDelete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item deleted')),
                  );
                },
                onArchive: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item completed')),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: const Text('Try swiping this item'),
                  subtitle: const Text('Swipe left or right'),
                  tileColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('5. Celebration Pattern'),
            _buildPatternCard(
              title: 'Achievement Unlocked',
              description: 'Positive feedback with confetti animation',
              pattern: 'Celebration',
              onDemo: () {
                setState(() => _celebrate = true);
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() => _celebrate = false);
                });
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('6. System Status'),
            _buildPatternCard(
              title: 'Progress Indicator',
              description: 'Shows current step in multi-step process',
              pattern: 'System Status',
              child: Column(
                children: [
                  StepProgressIndicator(
                    totalSteps: 4,
                    currentStep: _currentStep,
                    stepLabels: const ['Start', 'Progress', 'Review', 'Done'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _currentStep > 0
                            ? () => setState(() => _currentStep--)
                            : null,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _currentStep < 3
                            ? () => setState(() => _currentStep++)
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('7. Contextual Help'),
            _buildPatternCard(
              title: 'Just-in-Time Help',
              description: 'Help appears exactly when needed',
              pattern: 'Contextual Help',
              child: const Row(
                children: [
                  Expanded(
                    child: Text('Complex feature explanation'),
                  ),
                  ContextualHelpButton(
                    title: 'About This Feature',
                    message:
                        'This pattern provides help without cluttering the interface. Users can tap the help icon when they need clarification.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('8. Forgiving Interactions'),
            _buildPatternCard(
              title: 'Undo Action',
              description: 'Easy mistake recovery with undo',
              pattern: 'Forgiving',
              onDemo: () {
                UndoableAction(
                  message: 'Item deleted - you can undo this',
                  onUndo: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Action undone!')),
                    );
                  },
                ).show(context);
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('9. Smart Defaults'),
            _buildPatternCard(
              title: 'Intelligent Suggestions',
              description: 'Pre-filled with smart suggestions',
              pattern: 'Smart Defaults',
              child: SmartFormField(
                label: 'Task Title',
                smartDefault: 'Follow-up from meeting',
                onChanged: (value) {},
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('10. Modal Panel'),
            _buildPatternCard(
              title: 'Focused Task Completion',
              description: 'Modal panel for focused interaction',
              pattern: 'Modal Panel',
              onDemo: () {
                ModalBottomPanel.show(
                  context,
                  title: 'Create New Task',
                  saveLabel: 'Create',
                  onSave: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task created!')),
                    );
                  },
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Task title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('11. Pull to Refresh'),
            _buildPatternCard(
              title: 'Standard Mobile Gesture',
              description: 'Pull down to refresh content',
              pattern: 'Mobile Pattern',
              child: const Text(
                'Pull-to-refresh is integrated in all list screens throughout the app',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: Colors.blue.shade700),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Based on Tidwell\'s Book',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '"Designing Interfaces: Patterns for Effective Interaction Design" by Jenifer Tidwell',
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'All patterns demonstrated here are research-backed interaction design principles that improve usability, reduce cognitive load, and create delightful user experiences.',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPatternCard({
    required String title,
    required String description,
    required String pattern,
    VoidCallback? onDemo,
    Widget? child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onDemo != null)
                  ElevatedButton(
                    onPressed: onDemo,
                    child: const Text('Demo'),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'Pattern: $pattern',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: AppSpacing.lg),
              child,
            ],
          ],
        ),
      ),
    );
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FeatureTutorialOverlay(
          steps: const [
            TutorialStep(
              title: 'Welcome!',
              description:
                  'This tutorial demonstrates progressive disclosure - showing information step by step',
              icon: Icons.waving_hand,
            ),
            TutorialStep(
              title: 'Step 2',
              description: 'Users aren\'t overwhelmed with all information at once',
              icon: Icons.layers,
            ),
            TutorialStep(
              title: 'Complete!',
              description:
                  'They learn features when they\'re ready. This reduces cognitive load.',
              icon: Icons.check_circle,
            ),
          ],
          child: Container(
            height: 300,
            color: Colors.white,
            child: const Center(
              child: Text('Tutorial content behind overlay'),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmptyState() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyStateWidget(
            icon: Icons.inbox,
            title: 'No messages yet',
            description: 'Start a conversation with your team',
            actionLabel: 'New Message',
            onAction: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating new message...')),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSkeletonLoader() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 500,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Expanded(
                child: SkeletonLoader(
                  itemCount: 5,
                  itemHeight: 80,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Notice how the skeleton shows content structure while loading, making the wait feel shorter.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content loaded!')),
      );
    });
  }
}
