import 'dart:async';
import 'package:rxdart/rxdart.dart';

/// Debouncing utilities for search inputs and other rapid-fire events
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Execute callback after debounce duration
  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    cancel();
  }
}

/// Throttling utility - ensures callback is called at most once per duration
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isReady = true;

  Throttler({required this.duration});

  /// Execute callback if throttle period has elapsed
  void call(void Function() callback) {
    if (_isReady) {
      callback();
      _isReady = false;
      _timer = Timer(duration, () {
        _isReady = true;
      });
    }
  }

  /// Cancel and reset throttler
  void cancel() {
    _timer?.cancel();
    _isReady = true;
  }

  /// Dispose of the throttler
  void dispose() {
    cancel();
  }
}

/// Stream-based debouncer for reactive programming
class StreamDebouncer<T> {
  final Duration duration;
  final _controller = StreamController<T>();
  late final Stream<T> stream;

  StreamDebouncer({required this.duration}) {
    stream = _controller.stream.debounceTime(duration).distinct();
  }

  /// Add value to debounced stream
  void add(T value) {
    _controller.add(value);
  }

  /// Close the stream
  void dispose() {
    _controller.close();
  }
}

/// Common debounce durations
class DebounceDurations {
  /// Fast response (100ms) - for immediate feedback
  static const fast = Duration(milliseconds: 100);

  /// Standard search debounce (300ms) - recommended for search inputs
  static const search = Duration(milliseconds: 300);

  /// Medium delay (500ms) - for less critical operations
  static const medium = Duration(milliseconds: 500);

  /// Long delay (1000ms) - for expensive operations
  static const slow = Duration(milliseconds: 1000);
}

/// Throttle durations
class ThrottleDurations {
  /// Very fast (100ms) - for scroll listeners
  static const veryFast = Duration(milliseconds: 100);

  /// Fast (250ms) - for button clicks
  static const fast = Duration(milliseconds: 250);

  /// Medium (500ms) - for API calls
  static const medium = Duration(milliseconds: 500);

  /// Slow (1000ms) - for heavy operations
  static const slow = Duration(milliseconds: 1000);
}

/// Extension methods for easy debouncing
extension StreamDebounceExtension<T> on Stream<T> {
  /// Debounce this stream
  Stream<T> debounce(Duration duration) {
    return debounceTime(duration);
  }

  /// Throttle this stream
  Stream<T> throttle(Duration duration) {
    return throttleTime(duration);
  }
}
