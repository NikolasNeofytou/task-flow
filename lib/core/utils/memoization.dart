import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_item.dart';
import '../../theme/tokens.dart';

/// Memoization utilities for expensive computations
/// Caches results to avoid redundant calculations and improve performance

/// Memoized date formatter
class DateFormatCache {
  static final _cache = <String, DateFormat>{};
  
  /// Get or create a DateFormat with the given pattern
  static DateFormat getFormat(String pattern) {
    return _cache.putIfAbsent(pattern, () => DateFormat(pattern));
  }
  
  /// Format a date with caching
  static String format(DateTime date, String pattern) {
    return getFormat(pattern).format(date);
  }
  
  /// Common formats
  static String dayMonth(DateTime date) => format(date, 'MMM d');
  static String fullDate(DateTime date) => format(date, 'MMMM d, yyyy');
  static String time(DateTime date) => format(date, 'h:mm a');
  static String monthYear(DateTime date) => format(date, 'MMMM yyyy');
  static String shortDate(DateTime date) => format(date, 'M/d/yy');
}

/// Memoized status color mapping
class StatusColorCache {
  static final _cache = <TaskStatus, Color>{};
  
  static Color getColor(TaskStatus status) {
    return _cache.putIfAbsent(status, () {
      switch (status) {
        case TaskStatus.pending:
          return AppColors.warning;
        case TaskStatus.done:
          return AppColors.success;
        case TaskStatus.blocked:
          return AppColors.error;
      }
    });
  }
}

/// Memoized project status color mapping
class ProjectStatusColorCache {
  static final _cache = <String, Color>{};
  
  static Color getColor(String status) {
    return _cache.putIfAbsent(status, () {
      switch (status.toLowerCase()) {
        case 'ontrack':
          return AppColors.success;
        case 'duesoon':
          return AppColors.warning;
        case 'blocked':
          return AppColors.error;
        default:
          return AppColors.surface;
      }
    });
  }
}

/// Memoized string operations
class StringCache {
  static final _upperCache = <String, String>{};
  static final _lowerCache = <String, String>{};
  static final _truncateCache = <String, Map<int, String>>{};
  
  /// Cached uppercase conversion
  static String toUpperCase(String text) {
    return _upperCache.putIfAbsent(text, () => text.toUpperCase());
  }
  
  /// Cached lowercase conversion
  static String toLowerCase(String text) {
    return _lowerCache.putIfAbsent(text, () => text.toLowerCase());
  }
  
  /// Cached string truncation
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    
    final cache = _truncateCache.putIfAbsent(text, () => {});
    return cache.putIfAbsent(
      maxLength,
      () => '${text.substring(0, maxLength)}...',
    );
  }
  
  /// Clear all caches (call when memory pressure is high)
  static void clearAll() {
    _upperCache.clear();
    _lowerCache.clear();
    _truncateCache.clear();
  }
}

/// Memoized list filtering
class ListFilterCache<T> {
  final _cache = <String, List<T>>{};
  final int _maxCacheSize;
  
  ListFilterCache({int maxCacheSize = 50}) : _maxCacheSize = maxCacheSize;
  
  /// Get cached filtered list or compute and cache it
  List<T> getFiltered({
    required List<T> items,
    required String query,
    required bool Function(T item, String query) predicate,
  }) {
    // Create cache key
    final key = '$query-${items.length}';
    
    // Return cached result if available
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    // Compute and cache
    final filtered = items.where((item) => predicate(item, query)).toList();
    
    // Limit cache size (LRU-like behavior)
    if (_cache.length >= _maxCacheSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    
    _cache[key] = filtered;
    return filtered;
  }
  
  void clear() => _cache.clear();
}

/// Memoized computation wrapper
class Memoizer<T> {
  T? _cachedValue;
  dynamic _lastInput;
  
  /// Compute value with caching based on input
  T call(dynamic input, T Function(dynamic) compute) {
    if (_lastInput != input || _cachedValue == null) {
      _lastInput = input;
      _cachedValue = compute(input);
    }
    return _cachedValue!;
  }
  
  void clear() {
    _cachedValue = null;
    _lastInput = null;
  }
}

/// Global memoizers for common computations
final dateRangeMemoizer = Memoizer<List<DateTime>>();
final taskCountMemoizer = Memoizer<Map<String, int>>();
final progressMemoizer = Memoizer<double>();

/// Helper to clear all caches (useful for testing or memory management)
void clearAllCaches() {
  StringCache.clearAll();
  dateRangeMemoizer.clear();
  taskCountMemoizer.clear();
  progressMemoizer.clear();
}
