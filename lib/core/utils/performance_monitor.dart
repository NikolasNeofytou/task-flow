import 'dart:async';
import 'package:flutter/material.dart';

/// Performance monitoring utilities for tracking app performance
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};

  /// Start measuring a named operation
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// Stop measuring and record duration
  Duration stopTimer(String name) {
    final stopwatch = _timers[name];
    if (stopwatch == null) {
      debugPrint('⚠️ Timer not found: $name');
      return Duration.zero;
    }

    stopwatch.stop();
    final duration = stopwatch.elapsed;

    // Store measurement
    _measurements.putIfAbsent(name, () => []);
    _measurements[name]!.add(duration);

    // Log if slow
    if (duration.inMilliseconds > 100) {
      debugPrint('⚠️ Slow operation: $name took ${duration.inMilliseconds}ms');
    }

    _timers.remove(name);
    return duration;
  }

  /// Measure a synchronous function
  T measure<T>(String name, T Function() function) {
    startTimer(name);
    try {
      return function();
    } finally {
      stopTimer(name);
    }
  }

  /// Measure an asynchronous function
  Future<T> measureAsync<T>(String name, Future<T> Function() function) async {
    startTimer(name);
    try {
      return await function();
    } finally {
      stopTimer(name);
    }
  }

  /// Get average duration for a named operation
  Duration? getAverageDuration(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) return null;

    final total = measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );
    return Duration(microseconds: total ~/ measurements.length);
  }

  /// Get all measurements for a named operation
  List<Duration>? getMeasurements(String name) {
    return _measurements[name];
  }

  /// Clear all measurements
  void clear() {
    _timers.clear();
    _measurements.clear();
  }

  /// Print performance summary
  void printSummary() {
    debugPrint('=== Performance Summary ===');
    for (final entry in _measurements.entries) {
      final avg = getAverageDuration(entry.key);
      final count = entry.value.length;
      debugPrint('${entry.key}: ${avg?.inMilliseconds}ms avg ($count calls)');
    }
    debugPrint('==========================');
  }
}

/// Widget rebuild tracker
class RebuildTracker extends StatefulWidget {
  final String name;
  final Widget child;
  final bool enabled;

  const RebuildTracker({
    super.key,
    required this.name,
    required this.child,
    this.enabled = true,
  });

  @override
  State<RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<RebuildTracker> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      _buildCount++;
      if (_buildCount > 1) {
        debugPrint('🔄 Widget rebuilt: ${widget.name} ($_buildCount times)');
      }
    }
    return widget.child;
  }
}

/// Frame rate monitor
class FrameRateMonitor {
  static final FrameRateMonitor _instance = FrameRateMonitor._internal();
  factory FrameRateMonitor() => _instance;
  FrameRateMonitor._internal();

  final List<Duration> _frameDurations = [];
  DateTime? _lastFrameTime;
  bool _isMonitoring = false;

  /// Start monitoring frame rate
  void start() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _lastFrameTime = DateTime.now();
    _frameDurations.clear();

    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameDurations.add(frameDuration);

      // Keep only last 60 frames
      if (_frameDurations.length > 60) {
        _frameDurations.removeAt(0);
      }

      // Warn on janky frames (> 16ms)
      if (frameDuration.inMilliseconds > 16) {
        debugPrint('⚠️ Janky frame: ${frameDuration.inMilliseconds}ms');
      }
    }
    _lastFrameTime = now;

    WidgetsBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Stop monitoring
  void stop() {
    _isMonitoring = false;
    _lastFrameTime = null;
  }

  /// Get average FPS
  double? getAverageFps() {
    if (_frameDurations.isEmpty) return null;

    final avgDuration = _frameDurations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMicroseconds,
        ) /
        _frameDurations.length;

    return 1000000 / avgDuration; // Convert to FPS
  }

  /// Get percentage of janky frames
  double? getJankPercentage() {
    if (_frameDurations.isEmpty) return null;

    final jankyFrames = _frameDurations
        .where((duration) => duration.inMilliseconds > 16)
        .length;

    return (jankyFrames / _frameDurations.length) * 100;
  }

  /// Print frame rate summary
  void printSummary() {
    final fps = getAverageFps();
    final jank = getJankPercentage();

    debugPrint('=== Frame Rate Summary ===');
    debugPrint('Average FPS: ${fps?.toStringAsFixed(1) ?? 'N/A'}');
    debugPrint('Janky Frames: ${jank?.toStringAsFixed(1) ?? 'N/A'}%');
    debugPrint('==========================');
  }
}

/// Memory usage tracker
class MemoryMonitor {
  static void logMemoryUsage(String context) {
    // Note: Detailed memory monitoring requires platform channels
    // This is a placeholder for basic logging
    debugPrint('📊 Memory checkpoint: $context');
  }

  static void logImageCacheSize() {
    final cache = PaintingBinding.instance.imageCache;
    debugPrint(
        '🖼️ Image Cache: ${cache.currentSize}/${cache.maximumSize} images, '
        '${(cache.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB');
  }
}

/// Performance utilities
class PerformanceUtils {
  /// Measure build time of a widget
  static Widget measureBuild(String name, WidgetBuilder builder) {
    return Builder(
      builder: (context) {
        final stopwatch = Stopwatch()..start();
        final widget = builder(context);
        stopwatch.stop();

        if (stopwatch.elapsedMilliseconds > 16) {
          debugPrint(
              '⚠️ Slow widget build: $name (${stopwatch.elapsedMilliseconds}ms)');
        }

        return widget;
      },
    );
  }

  /// Delay execution until after current frame
  static void afterFrame(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  /// Schedule execution on next frame
  static void onNextFrame(VoidCallback callback) {
    WidgetsBinding.instance.scheduleFrameCallback((_) => callback());
  }
}
