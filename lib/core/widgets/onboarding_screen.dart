import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding service to manage tutorial state
class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _hasSeenFeatureKey = 'has_seen_feature_';

  /// Check if user has completed onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenOnboardingKey);
    // Reset all feature tutorials
    final keys = prefs.getKeys().where((k) => k.startsWith(_hasSeenFeatureKey));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Check if user has seen a specific feature tutorial
  static Future<bool> hasSeenFeature(String featureName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_hasSeenFeatureKey$featureName') ?? false;
  }

  /// Mark feature tutorial as seen
  static Future<void> markFeatureAsSeen(String featureName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_hasSeenFeatureKey$featureName', true);
  }
}

/// Onboarding screen with step-by-step tutorial
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to TaskFlow',
      description: 'Manage your projects and tasks efficiently with your team',
      icon: Icons.rocket_launch,
      color: Colors.blue,
    ),
    OnboardingPage(
      title: 'Create Projects',
      description: 'Organize your work into projects and invite team members',
      icon: Icons.folder,
      color: Colors.green,
    ),
    OnboardingPage(
      title: 'Track Tasks',
      description:
          'Create, assign, and track tasks with deadlines and priorities',
      icon: Icons.check_circle,
      color: Colors.orange,
    ),
    OnboardingPage(
      title: 'Collaborate',
      description: 'Chat, share files, and work together in real-time',
      icon: Icons.people,
      color: Colors.purple,
    ),
    OnboardingPage(
      title: 'Stay Notified',
      description: 'Get notifications for updates, mentions, and deadlines',
      icon: Icons.notifications,
      color: Colors.red,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _complete() async {
    await OnboardingService.completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: const Text('Skip'),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          page.description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

/// Data model for onboarding page
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Feature tooltip widget for in-app tutorials
class FeatureTooltip extends StatelessWidget {
  final String featureName;
  final String title;
  final String description;
  final Widget child;
  final bool showOnFirstVisit;

  const FeatureTooltip({
    super.key,
    required this.featureName,
    required this.title,
    required this.description,
    required this.child,
    this.showOnFirstVisit = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showOnFirstVisit) return child;

    return FutureBuilder<bool>(
      future: OnboardingService.hasSeenFeature(featureName),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == true) {
          return child;
        }

        // Show tooltip on first visit
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTooltip(context);
        });

        return child;
      },
    );
  }

  void _showTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () {
              OnboardingService.markFeatureAsSeen(featureName);
              Navigator.pop(context);
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
