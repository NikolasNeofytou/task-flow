import 'package:flutter/material.dart';

/// Advanced search utilities with fuzzy matching and highlighting
/// Provides intelligent search across multiple fields with ranking

/// Search result with relevance score and match highlights
class SearchResult<T> {
  final T item;
  final double score;
  final List<SearchMatch> matches;
  
  const SearchResult({
    required this.item,
    required this.score,
    required this.matches,
  });
}

/// Individual field match with position
class SearchMatch {
  final String field;
  final String matchedText;
  final int startIndex;
  final int endIndex;
  
  const SearchMatch({
    required this.field,
    required this.matchedText,
    required this.startIndex,
    required this.endIndex,
  });
}

/// Fuzzy search engine with configurable options
class FuzzySearchEngine<T> {
  final double threshold;
  final bool caseSensitive;
  final int maxResults;
  
  FuzzySearchEngine({
    this.threshold = 0.3,
    this.caseSensitive = false,
    this.maxResults = 50,
  });
  
  /// Search items using multiple field extractors
  List<SearchResult<T>> search({
    required String query,
    required List<T> items,
    required Map<String, String Function(T)> fieldExtractors,
    Map<String, double>? fieldWeights,
  }) {
    if (query.isEmpty) return [];
    
    final normalizedQuery = caseSensitive ? query : query.toLowerCase();
    final results = <SearchResult<T>>[];
    
    for (final item in items) {
      double totalScore = 0;
      final matches = <SearchMatch>[];
      
      // Search each field
      for (final entry in fieldExtractors.entries) {
        final fieldName = entry.key;
        final fieldValue = entry.value(item);
        final normalizedValue = caseSensitive ? fieldValue : fieldValue.toLowerCase();
        final weight = fieldWeights?[fieldName] ?? 1.0;
        
        // Calculate field score
        final fieldScore = _calculateFieldScore(
          normalizedQuery,
          normalizedValue,
          fieldValue,
          fieldName,
          matches,
        );
        
        totalScore += fieldScore * weight;
      }
      
      // Only include results above threshold
      if (totalScore >= threshold && matches.isNotEmpty) {
        results.add(SearchResult(
          item: item,
          score: totalScore,
          matches: matches,
        ));
      }
    }
    
    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    
    // Limit results
    return results.take(maxResults).toList();
  }
  
  double _calculateFieldScore(
    String query,
    String normalizedValue,
    String originalValue,
    String fieldName,
    List<SearchMatch> matches,
  ) {
    // Exact match (highest score)
    if (normalizedValue == query) {
      matches.add(SearchMatch(
        field: fieldName,
        matchedText: originalValue,
        startIndex: 0,
        endIndex: originalValue.length,
      ));
      return 1.0;
    }
    
    // Starts with query (high score)
    if (normalizedValue.startsWith(query)) {
      matches.add(SearchMatch(
        field: fieldName,
        matchedText: originalValue.substring(0, query.length),
        startIndex: 0,
        endIndex: query.length,
      ));
      return 0.9;
    }
    
    // Contains query (medium score)
    final index = normalizedValue.indexOf(query);
    if (index >= 0) {
      matches.add(SearchMatch(
        field: fieldName,
        matchedText: originalValue.substring(index, index + query.length),
        startIndex: index,
        endIndex: index + query.length,
      ));
      return 0.7;
    }
    
    // Fuzzy match (lower score)
    final fuzzyScore = _levenshteinSimilarity(query, normalizedValue);
    if (fuzzyScore > 0.5) {
      matches.add(SearchMatch(
        field: fieldName,
        matchedText: originalValue,
        startIndex: 0,
        endIndex: originalValue.length,
      ));
      return fuzzyScore * 0.5;
    }
    
    return 0.0;
  }
  
  /// Calculate Levenshtein similarity (0.0 to 1.0)
  double _levenshteinSimilarity(String s1, String s2) {
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    if (maxLength == 0) return 1.0;
    return 1.0 - (distance / maxLength);
  }
  
  /// Calculate Levenshtein distance
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    
    final matrix = List.generate(
      len1 + 1,
      (i) => List.filled(len2 + 1, 0),
    );
    
    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }
    
    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    
    return matrix[len1][len2];
  }
}

/// Text highlighter for search results
class TextHighlighter {
  /// Highlight matches in text with rich text spans
  static List<TextSpan> highlight({
    required String text,
    required List<SearchMatch> matches,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (matches.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }
    
    final spans = <TextSpan>[];
    var lastEnd = 0;
    
    // Sort matches by start index
    final sortedMatches = matches.toList()
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));
    
    for (final match in sortedMatches) {
      // Add text before match
      if (match.startIndex > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.startIndex),
          style: baseStyle,
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(match.startIndex, match.endIndex),
        style: highlightStyle,
      ));
      
      lastEnd = match.endIndex;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }
    
    return spans;
  }
  
  /// Create a RichText widget with highlights
  static Widget buildHighlightedText({
    required String text,
    required List<SearchMatch> matches,
    required TextStyle baseStyle,
    Color? highlightColor,
    FontWeight? highlightWeight,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final highlightStyle = baseStyle.copyWith(
      backgroundColor: highlightColor ?? Colors.yellow.withOpacity(0.3),
      fontWeight: highlightWeight ?? FontWeight.bold,
    );
    
    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      text: TextSpan(
        children: highlight(
          text: text,
          matches: matches,
          baseStyle: baseStyle,
          highlightStyle: highlightStyle,
        ),
      ),
    );
  }
}

/// Search filter helpers
class SearchFilters {
  /// Filter by date range
  static bool inDateRange(
    DateTime date,
    DateTime? start,
    DateTime? end,
  ) {
    if (start != null && date.isBefore(start)) return false;
    if (end != null && date.isAfter(end)) return false;
    return true;
  }
  
  /// Filter by multiple tags (any match)
  static bool hasAnyTag(List<String> itemTags, List<String> filterTags) {
    if (filterTags.isEmpty) return true;
    return itemTags.any((tag) => filterTags.contains(tag));
  }
  
  /// Filter by multiple tags (all match)
  static bool hasAllTags(List<String> itemTags, List<String> filterTags) {
    if (filterTags.isEmpty) return true;
    return filterTags.every((tag) => itemTags.contains(tag));
  }
  
  /// Combine multiple filter predicates with AND
  static bool Function(T) combineAnd<T>(
    List<bool Function(T)> predicates,
  ) {
    return (item) => predicates.every((predicate) => predicate(item));
  }
  
  /// Combine multiple filter predicates with OR
  static bool Function(T) combineOr<T>(
    List<bool Function(T)> predicates,
  ) {
    return (item) => predicates.any((predicate) => predicate(item));
  }
}

/// Search history manager
class SearchHistory {
  final int maxHistory;
  final List<String> _history = [];
  
  SearchHistory({this.maxHistory = 20});
  
  /// Add search query to history
  void add(String query) {
    if (query.trim().isEmpty) return;
    
    // Remove existing occurrence
    _history.remove(query);
    
    // Add to front
    _history.insert(0, query);
    
    // Trim to max size
    if (_history.length > maxHistory) {
      _history.removeRange(maxHistory, _history.length);
    }
  }
  
  /// Get search history (most recent first)
  List<String> get history => List.unmodifiable(_history);
  
  /// Clear history
  void clear() => _history.clear();
  
  /// Get suggestions based on partial query
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return history;
    
    final normalized = query.toLowerCase();
    return _history
        .where((h) => h.toLowerCase().startsWith(normalized))
        .toList();
  }
}
