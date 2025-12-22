import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for caching QR codes for offline use
class QRCacheService {
  static const _storage = FlutterSecureStorage();
  static const _cacheKey = 'qr_code_cache';
  static const _scanQueueKey = 'qr_scan_queue';

  /// Cache a QR code for offline viewing
  Future<void> cacheQRCode({
    required String id,
    required String data,
    required String type, // 'user' or 'project'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final cache = await _getCache();
      
      cache[id] = {
        'data': data,
        'type': type,
        'metadata': metadata ?? {},
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _saveCache(cache);
    } catch (e) {
      throw Exception('Failed to cache QR code: $e');
    }
  }

  /// Get a cached QR code
  Future<Map<String, dynamic>?> getCachedQRCode(String id) async {
    try {
      final cache = await _getCache();
      return cache[id];
    } catch (e) {
      return null;
    }
  }

  /// Get all cached QR codes
  Future<List<Map<String, dynamic>>> getAllCachedQRCodes() async {
    try {
      final cache = await _getCache();
      return cache.entries
          .map((e) => <String, dynamic>{
                'id': e.key,
                ...Map<String, dynamic>.from(e.value),
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove a cached QR code
  Future<void> removeCachedQRCode(String id) async {
    try {
      final cache = await _getCache();
      cache.remove(id);
      await _saveCache(cache);
    } catch (e) {
      throw Exception('Failed to remove cached QR code: $e');
    }
  }

  /// Clear all cached QR codes
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: _cacheKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Queue a QR code scan for later processing (offline support)
  Future<void> queueScan({
    required String qrData,
    required DateTime scannedAt,
    Map<String, dynamic>? context,
  }) async {
    try {
      final queue = await _getScanQueue();
      
      queue.add({
        'qrData': qrData,
        'scannedAt': scannedAt.toIso8601String(),
        'context': context ?? {},
        'processed': false,
      });

      await _saveScanQueue(queue);
    } catch (e) {
      throw Exception('Failed to queue scan: $e');
    }
  }

  /// Get all queued scans
  Future<List<Map<String, dynamic>>> getQueuedScans() async {
    try {
      return await _getScanQueue();
    } catch (e) {
      return [];
    }
  }

  /// Mark a queued scan as processed
  Future<void> markScanProcessed(int index) async {
    try {
      final queue = await _getScanQueue();
      if (index >= 0 && index < queue.length) {
        queue[index]['processed'] = true;
        await _saveScanQueue(queue);
      }
    } catch (e) {
      throw Exception('Failed to mark scan as processed: $e');
    }
  }

  /// Remove a queued scan
  Future<void> removeQueuedScan(int index) async {
    try {
      final queue = await _getScanQueue();
      if (index >= 0 && index < queue.length) {
        queue.removeAt(index);
        await _saveScanQueue(queue);
      }
    } catch (e) {
      throw Exception('Failed to remove queued scan: $e');
    }
  }

  /// Process all queued scans
  Future<List<Map<String, dynamic>>> processQueuedScans() async {
    try {
      final queue = await _getScanQueue();
      final unprocessed = queue
          .where((scan) => scan['processed'] == false)
          .toList();
      return unprocessed;
    } catch (e) {
      return [];
    }
  }

  /// Clear the scan queue
  Future<void> clearScanQueue() async {
    try {
      await _storage.delete(key: _scanQueueKey);
    } catch (e) {
      throw Exception('Failed to clear scan queue: $e');
    }
  }

  // Private helper methods

  Future<Map<String, dynamic>> _getCache() async {
    try {
      final cacheJson = await _storage.read(key: _cacheKey);
      if (cacheJson == null) return {};
      return Map<String, dynamic>.from(json.decode(cacheJson));
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveCache(Map<String, dynamic> cache) async {
    await _storage.write(key: _cacheKey, value: json.encode(cache));
  }

  Future<List<Map<String, dynamic>>> _getScanQueue() async {
    try {
      final queueJson = await _storage.read(key: _scanQueueKey);
      if (queueJson == null) return [];
      final List<dynamic> decoded = json.decode(queueJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveScanQueue(List<Map<String, dynamic>> queue) async {
    await _storage.write(key: _scanQueueKey, value: json.encode(queue));
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cache = await _getCache();
      final queue = await _getScanQueue();
      
      final userQRs = cache.values.where((v) => v['type'] == 'user').length;
      final projectQRs = cache.values.where((v) => v['type'] == 'project').length;
      final pendingScans = queue.where((s) => s['processed'] == false).length;
      
      return {
        'totalCached': cache.length,
        'userQRs': userQRs,
        'projectQRs': projectQRs,
        'queuedScans': queue.length,
        'pendingScans': pendingScans,
      };
    } catch (e) {
      return {
        'totalCached': 0,
        'userQRs': 0,
        'projectQRs': 0,
        'queuedScans': 0,
        'pendingScans': 0,
      };
    }
  }
}
