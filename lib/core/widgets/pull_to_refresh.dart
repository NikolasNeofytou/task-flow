import 'package:flutter/material.dart';

/// Pull to refresh wrapper with custom indicator
class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).primaryColor,
      child: child,
    );
  }
}

/// Infinite scroll list view with pagination
class InfiniteScrollListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const InfiniteScrollListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.physics,
    this.padding,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<InfiniteScrollListView<T>> createState() =>
      _InfiniteScrollListViewState<T>();
}

class _InfiniteScrollListViewState<T> extends State<InfiniteScrollListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold) {
      if (widget.hasMore && !widget.isLoading) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        } else {
          // Loading indicator at bottom
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Infinite scroll grid view with pagination
class InfiniteScrollGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final EdgeInsets? padding;
  final double loadMoreThreshold;

  const InfiniteScrollGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.emptyWidget,
    this.loadingWidget,
    this.padding,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<InfiniteScrollGridView<T>> createState() =>
      _InfiniteScrollGridViewState<T>();
}

class _InfiniteScrollGridViewState<T> extends State<InfiniteScrollGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold) {
      if (widget.hasMore && !widget.isLoading) {
        widget.onLoadMore();
      }
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
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          return widget.itemBuilder(context, widget.items[index], index);
        } else {
          // Loading indicator at bottom
          return Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

/// Combined pull-to-refresh and infinite scroll
class PullToRefreshInfiniteList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const PullToRefreshInfiniteList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.emptyWidget,
    this.loadingWidget,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PullToRefreshWrapper(
      onRefresh: onRefresh,
      child: InfiniteScrollListView<T>(
        items: items,
        itemBuilder: itemBuilder,
        onLoadMore: onLoadMore,
        hasMore: hasMore,
        isLoading: isLoading,
        emptyWidget: emptyWidget,
        loadingWidget: loadingWidget,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        padding: padding,
      ),
    );
  }
}
