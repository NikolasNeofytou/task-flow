import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/tokens.dart';
import '../../../design_system/animations/micro_interactions.dart';

/// Interactive tour provider
final interactiveTourProvider = StateNotifierProvider<InteractiveTourNotifier, InteractiveTourState>((ref) {
  return InteractiveTourNotifier();
});

/// Tour state
class InteractiveTourState {
  final bool isActive;
  final int currentStep;
  final bool hasCompletedTour;
  
  const InteractiveTourState({
    this.isActive = false,
    this.currentStep = 0,
    this.hasCompletedTour = false,
  });
  
  InteractiveTourState copyWith({
    bool? isActive,
    int? currentStep,
    bool? hasCompletedTour,
  }) {
    return InteractiveTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
    );
  }
}

class InteractiveTourNotifier extends StateNotifier<InteractiveTourState> {
  InteractiveTourNotifier() : super(const InteractiveTourState());
  
  void startTour() {
    state = state.copyWith(isActive: true, currentStep: 0);
  }
  
  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }
  
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
  
  void skipTour() {
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
    );
  }
  
  void completeTour() {
    state = state.copyWith(
      isActive: false,
      hasCompletedTour: true,
    );
  }
  
  void resetTour() {
    state = const InteractiveTourState();
  }
}

/// Tour step definition
class TourStep {
  final String targetKey;
  final String title;
  final String description;
  final IconData icon;
  final Alignment tooltipAlignment;
  
  const TourStep({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    this.tooltipAlignment = Alignment.bottomCenter,
  });
}

/// Predefined tour steps for calendar screen
class CalendarTourSteps {
  static const steps = [
    TourStep(
      targetKey: 'calendar_grid',
      title: 'Calendar View',
      description: 'See all your tasks organized by date. Tap any date to view tasks for that day.',
      icon: Icons.calendar_today,
      tooltipAlignment: Alignment.topCenter,
    ),
    TourStep(
      targetKey: 'today_button',
      title: 'Jump to Today',
      description: 'Quickly navigate back to today\'s date with this handy button.',
      icon: Icons.today,
      tooltipAlignment: Alignment.bottomLeft,
    ),
    TourStep(
      targetKey: 'month_navigation',
      title: 'Navigate Months',
      description: 'Use the arrows to browse through different months.',
      icon: Icons.navigate_next,
      tooltipAlignment: Alignment.bottomCenter,
    ),
    TourStep(
      targetKey: 'task_card',
      title: 'Task Cards',
      description: 'Tap a task to view details. Swipe left to delete or right to complete.',
      icon: Icons.task,
      tooltipAlignment: Alignment.topLeft,
    ),
  ];
}

class ProjectsTourSteps {
  static const steps = [
    TourStep(
      targetKey: 'projects_list',
      title: 'Your Projects',
      description: 'All your projects are listed here. Tap one to view its tasks and details.',
      icon: Icons.folder,
      tooltipAlignment: Alignment.topCenter,
    ),
    TourStep(
      targetKey: 'new_project_button',
      title: 'Create Project',
      description: 'Tap here to create a new project. Organize tasks into projects for better management.',
      icon: Icons.add,
      tooltipAlignment: Alignment.bottomRight,
    ),
    TourStep(
      targetKey: 'project_status',
      title: 'Project Status',
      description: 'See at a glance if a project is on track, due soon, or blocked.',
      icon: Icons.info_outline,
      tooltipAlignment: Alignment.bottomLeft,
    ),
  ];
}

/// Tour overlay widget
class TourOverlay extends ConsumerWidget {
  final Widget child;
  final List<TourStep> tourSteps;
  
  const TourOverlay({
    super.key,
    required this.child,
    required this.tourSteps,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(interactiveTourProvider);
    
    if (!tourState.isActive) {
      return child;
    }
    
    if (tourState.currentStep >= tourSteps.length) {
      // Tour completed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(interactiveTourProvider.notifier).completeTour();
      });
      return child;
    }
    
    final currentTourStep = tourSteps[tourState.currentStep];
    
    return Stack(
      children: [
        child,
        
        // Dark overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.7),
          ),
        ),
        
        // Tour tooltip
        Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: currentTourStep.tooltipAlignment,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _TourTooltip(
                  step: currentTourStep,
                  currentStep: tourState.currentStep,
                  totalSteps: tourSteps.length,
                  onNext: () {
                    ref.read(interactiveTourProvider.notifier).nextStep();
                  },
                  onPrevious: tourState.currentStep > 0
                      ? () {
                          ref.read(interactiveTourProvider.notifier).previousStep();
                        }
                      : null,
                  onSkip: () {
                    ref.read(interactiveTourProvider.notifier).skipTour();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TourTooltip extends StatelessWidget {
  final TourStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;
  
  const _TourTooltip({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    this.onPrevious,
    required this.onSkip,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and step counter
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    step.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  '${currentStep + 1}/$totalSteps',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Title
            Text(
              step.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Description
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Progress indicator
            Row(
              children: List.generate(
                totalSteps,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < totalSteps - 1 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Action buttons
            Row(
              children: [
                // Skip button
                TextButton(
                  onPressed: onSkip,
                  child: const Text('Skip'),
                ),
                
                const Spacer(),
                
                // Previous button
                if (onPrevious != null)
                  TextButton(
                    onPressed: onPrevious,
                    child: const Text('Back'),
                  ),
                
                const SizedBox(width: AppSpacing.sm),
                
                // Next button
                PressableScale(
                  onTap: onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      currentStep == totalSteps - 1 ? 'Finish' : 'Next',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tour launcher button
class TourLauncherButton extends ConsumerWidget {
  const TourLauncherButton({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourState = ref.watch(interactiveTourProvider);
    
    if (tourState.isActive) {
      return const SizedBox.shrink();
    }
    
    return FloatingActionButton.extended(
      onPressed: () {
        ref.read(interactiveTourProvider.notifier).startTour();
      },
      icon: const Icon(Icons.help_outline),
      label: const Text('Start Tour'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }
}
