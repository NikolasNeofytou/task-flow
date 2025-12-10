import 'dart:async';
import 'package:flutter/material.dart';

/// Debouncer for delaying execution until input stops changing
/// Useful for search inputs, form validation, and API calls
class Debouncer {
  final Duration delay;
  Timer? _timer;
  
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  
  /// Run the action after the delay period with no new calls
  void run(void Function() action) {
    // Cancel existing timer
    _timer?.cancel();
    
    // Start new timer
    _timer = Timer(delay, action);
  }
  
  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// Dispose and clean up
  void dispose() {
    cancel();
  }
  
  /// Check if there's a pending action
  bool get isActive => _timer?.isActive ?? false;
}

/// Throttler for rate-limiting execution
/// Ensures action runs at most once per interval
class Throttler {
  final Duration interval;
  DateTime? _lastRun;
  Timer? _timer;
  
  Throttler({this.interval = const Duration(milliseconds: 500)});
  
  /// Run the action if enough time has passed since last run
  void run(void Function() action) {
    final now = DateTime.now();
    
    // If no last run or enough time has passed, run immediately
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      action();
      return;
    }
    
    // Otherwise schedule for later
    _timer?.cancel();
    final remaining = interval - now.difference(_lastRun!);
    _timer = Timer(remaining, () {
      _lastRun = DateTime.now();
      action();
    });
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

/// Async debouncer for Future-returning functions
class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;
  Completer<void>? _completer;
  
  AsyncDebouncer({this.delay = const Duration(milliseconds: 300)});
  
  /// Run async action with debouncing
  Future<T> run<T>(Future<T> Function() action) {
    // Cancel existing timer and completer
    _timer?.cancel();
    _completer?.complete();
    
    // Create new completer
    final completer = Completer<T>();
    _completer = Completer<void>();
    
    // Start new timer
    _timer = Timer(delay, () async {
      try {
        final result = await action();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });
    
    return completer.future;
  }
  
  void cancel() {
    _timer?.cancel();
    _completer?.complete();
  }
  
  void dispose() {
    cancel();
  }
}

/// Extension on TextEditingController for easy debouncing
extension DebouncedTextController on TextEditingController {
  /// Listen to text changes with debouncing
  void addDebouncedListener(
    void Function(String text) onChanged, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    final debouncer = Debouncer(delay: delay);
    addListener(() {
      debouncer.run(() => onChanged(text));
    });
  }
}
