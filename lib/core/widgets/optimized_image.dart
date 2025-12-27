import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized cached image widget with error handling and shimmer loading
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool showShimmer;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.showShimmer = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor =
        shimmerBaseColor ?? theme.colorScheme.surfaceContainerHighest;
    final highlightColor = shimmerHighlightColor ?? theme.colorScheme.surface;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : showShimmer
              ? (context, url) => Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      width: width,
                      height: height,
                      color: baseColor,
                    ),
                  )
              : (context, url) => Container(
                    width: width,
                    height: height,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : (context, url, error) => Container(
                width: width,
                height: height,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Circular avatar with cached network image
class OptimizedAvatarImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;

  const OptimizedAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;

    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: bgColor,
            child: Center(
              child: Text(
                fallbackText ?? '',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.6,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: bgColor,
            child: Icon(
              Icons.person,
              size: radius * 1.2,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          memCacheWidth: (radius * 2).toInt(),
          memCacheHeight: (radius * 2).toInt(),
        ),
      ),
    );
  }
}

/// Image cache configuration utilities
class ImageCacheConfig {
  /// Configure global image cache settings
  static void configure({
    int maxCacheSize = 100,
    int maxCacheSizeBytes = 50 * 1024 * 1024, // 50 MB
  }) {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = maxCacheSize;
    imageCache.maximumSizeBytes = maxCacheSizeBytes;
  }

  /// Clear image cache
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'maximumSize': cache.maximumSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSizeBytes': cache.maximumSizeBytes,
      'liveImageCount': cache.liveImageCount,
      'pendingImageCount': cache.pendingImageCount,
    };
  }

  /// Log cache statistics
  static void logCacheStats() {
    final stats = getCacheStats();
    debugPrint('=== Image Cache Stats ===');
    debugPrint('Images: ${stats['currentSize']}/${stats['maximumSize']}');
    debugPrint(
        'Memory: ${(stats['currentSizeBytes'] / 1024 / 1024).toStringAsFixed(1)} MB / '
        '${(stats['maximumSizeBytes'] / 1024 / 1024).toStringAsFixed(1)} MB');
    debugPrint(
        'Live: ${stats['liveImageCount']}, Pending: ${stats['pendingImageCount']}');
    debugPrint('========================');
  }
}
