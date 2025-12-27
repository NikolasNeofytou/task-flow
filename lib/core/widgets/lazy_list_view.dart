import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Lazy list view that loads items on demand with pagination support
class LazyListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? separatorBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final int? cacheExtent;

  const LazyListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 0.8,
    this.cacheExtent,
  });

  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    widget.onLoadMore?.call();

    // Reset loading state after a delay to prevent rapid calls
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      cacheExtent: widget.cacheExtent?.toDouble(),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) {
        if (widget.separatorBuilder != null &&
            index < widget.items.length - 1) {
          return widget.separatorBuilder!(context);
        }
        return const SizedBox.shrink();
      },
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          // Loading indicator at bottom
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
        }

        final item = widget.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// Lazy grid view with pagination support
class LazyGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const LazyGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.scrollController,
    this.padding,
    this.loadMoreThreshold = 0.8,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
  });

  @override
  State<LazyGridView<T>> createState() => _LazyGridViewState<T>();
}

class _LazyGridViewState<T> extends State<LazyGridView<T>> {
  late final ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    widget.onLoadMore?.call();

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return widget.loadingWidget ??
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }

        final item = widget.items[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// Lazy loading item with visibility detection
class LazyLoadItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onVisible;
  final String? itemKey;

  const LazyLoadItem({
    super.key,
    required this.child,
    this.onVisible,
    this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    if (onVisible == null) return child;

    return VisibilityDetector(
      key: Key(itemKey ?? UniqueKey().toString()),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          onVisible?.call();
        }
      },
      child: child,
    );
  }
}

/// Sliver lazy list for use in CustomScrollView
class SliverLazyList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final bool hasMore;
  final Widget? loadingWidget;

  const SliverLazyList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.hasMore = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= items.length) {
            return loadingWidget ??
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
          }

          final item = items[index];
          return itemBuilder(context, item, index);
        },
        childCount: items.length + (hasMore ? 1 : 0),
      ),
    );
  }
}
