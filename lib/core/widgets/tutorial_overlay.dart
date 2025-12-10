import 'package:flutter/material.dart';

/// Interactive tutorial overlay that guides users through features
/// Pattern: Progressive Disclosure - Show information when needed
class FeatureTutorialOverlay extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final bool showOnFirstLaunch;

  const FeatureTutorialOverlay({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
    this.showOnFirstLaunch = true,
  });

  @override
  State<FeatureTutorialOverlay> createState() => _FeatureTutorialOverlayState();
}

class _FeatureTutorialOverlayState extends State<FeatureTutorialOverlay> {
  int _currentStep = 0;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    if (widget.showOnFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showTutorial = true);
      });
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _complete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skip() {
    setState(() => _showTutorial = false);
    widget.onComplete?.call();
  }

  void _complete() {
    setState(() => _showTutorial = false);
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTutorial) ...[
          // Semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // Tutorial spotlight
          _buildSpotlight(),
          // Tutorial content
          _buildTutorialContent(),
        ],
      ],
    );
  }

  Widget _buildSpotlight() {
    final step = widget.steps[_currentStep];
    if (step.targetKey == null) return const SizedBox.shrink();

    return CustomPaint(
      painter: SpotlightPainter(
        targetKey: step.targetKey!,
        radius: step.spotlightRadius,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildTutorialContent() {
    final step = widget.steps[_currentStep];

    return Positioned(
      left: 20,
      right: 20,
      bottom: 100,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentStep
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Icon
              if (step.icon != null) ...[
                Icon(step.icon, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
              ],
              
              // Title
              Text(
                step.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                step.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip'),
                  ),
                  Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previousStep,
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(
                          _currentStep == widget.steps.length - 1
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData? icon;
  final GlobalKey? targetKey;
  final double spotlightRadius;

  const TutorialStep({
    required this.title,
    required this.description,
    this.icon,
    this.targetKey,
    this.spotlightRadius = 60,
  });
}

class SpotlightPainter extends CustomPainter {
  final GlobalKey targetKey;
  final double radius;

  SpotlightPainter({
    required this.targetKey,
    this.radius = 60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final renderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final targetSize = renderBox.size;
    final center = Offset(
      position.dx + targetSize.width / 2,
      position.dy + targetSize.height / 2,
    );

    // Create hole in overlay
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
