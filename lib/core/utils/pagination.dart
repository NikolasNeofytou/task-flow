/// Pagination utilities for efficient list loading
/// Supports page-based and cursor-based pagination
library;

/// Pagination state container
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final String? cursor;

  const PaginationState({
    required this.items,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.error,
    this.cursor,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
    bool? isLoading,
    String? error,
    String? cursor,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cursor: cursor ?? this.cursor,
    );
  }

  /// Create initial empty state
  factory PaginationState.initial() {
    return const PaginationState(
      items: [],
      currentPage: 0,
      hasMore: true,
    );
  }

  /// Create loading state
  PaginationState<T> toLoading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Create success state with new items
  PaginationState<T> toSuccess({
    required List<T> newItems,
    required int page,
    required int totalPages,
    required int totalItems,
    String? cursor,
  }) {
    final allItems = page == 1 ? newItems : [...items, ...newItems];
    return PaginationState<T>(
      items: allItems,
      currentPage: page,
      totalPages: totalPages,
      totalItems: totalItems,
      hasMore: page < totalPages,
      isLoading: false,
      error: null,
      cursor: cursor,
    );
  }

  /// Create error state
  PaginationState<T> toError(String error) {
    return copyWith(isLoading: false, error: error);
  }

  /// Check if we should load more
  bool get shouldLoadMore => hasMore && !isLoading && error == null;
}

/// Response model for paginated API calls
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final String? nextCursor;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    this.nextCursor,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      nextCursor: json['nextCursor'] as String?,
    );
  }
}

/// Pagination configuration
class PaginationConfig {
  /// Items per page
  final int pageSize;

  /// Threshold for triggering load more (e.g., 0.8 = when 80% scrolled)
  final double loadMoreThreshold;

  /// Maximum cached pages
  final int maxCachedPages;

  const PaginationConfig({
    this.pageSize = 20,
    this.loadMoreThreshold = 0.8,
    this.maxCachedPages = 5,
  });

  /// Default configuration
  static const defaultConfig = PaginationConfig();

  /// Small page size for slower networks
  static const small = PaginationConfig(pageSize: 10);

  /// Large page size for fast connections
  static const large = PaginationConfig(pageSize: 50);
}
