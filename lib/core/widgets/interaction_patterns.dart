import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

/// Celebration pattern - Positive feedback for achievements
class CelebrationAnimation extends StatefulWidget {
  final Widget child;
  final bool celebrate;
  final String? message;

  const CelebrationAnimation({
    super.key,
    required this.child,
    this.celebrate = false,
    this.message,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(CelebrationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.celebrate && !oldWidget.celebrate) {
      _confettiController.play();
      if (widget.message != null) {
        _showCelebrationMessage();
      }
    }
  }

  void _showCelebrationMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.message!)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // downward
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }
}

/// Progress indicator pattern - Show system status
class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1) const SizedBox(width: 4),
                ],
              ),
            );
          }),
        ),
        if (stepLabels != null && stepLabels!.length == totalSteps) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels!.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;

              return Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isCompleted || isCurrent
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Contextual help pattern - Just-in-time information
class ContextualHelpButton extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const ContextualHelpButton({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.help_outline,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: Colors.grey),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Undo pattern - Forgiving interactions
class UndoableAction extends StatelessWidget {
  final String message;
  final VoidCallback onUndo;
  final Duration duration;

  const UndoableAction({
    super.key,
    required this.message,
    required this.onUndo,
    this.duration = const Duration(seconds: 5),
  });

  void show(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: onUndo,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Smart defaults pattern - Reduce cognitive load
class SmartFormField extends StatefulWidget {
  final String label;
  final String? smartDefault;
  final Function(String) onChanged;
  final String? Function(String?)? validator;

  const SmartFormField({
    super.key,
    required this.label,
    this.smartDefault,
    required this.onChanged,
    this.validator,
  });

  @override
  State<SmartFormField> createState() => _SmartFormFieldState();
}

class _SmartFormFieldState extends State<SmartFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.smartDefault);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.smartDefault != null
            ? 'Smart suggestion: ${widget.smartDefault}'
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}

/// Modal panel pattern - Focused task completion
class ModalBottomPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final String? saveLabel;

  const ModalBottomPanel({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.saveLabel,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    VoidCallback? onSave,
    String? saveLabel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalBottomPanel(
        title: title,
        onSave: onSave,
        saveLabel: saveLabel,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
          
          // Action button
          if (onSave != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave!();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(saveLabel ?? 'Save'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
