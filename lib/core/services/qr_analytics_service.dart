import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for tracking QR code usage analytics
class QRAnalyticsService {
  static const _storage = FlutterSecureStorage();
  static const _analyticsKey = 'qr_analytics';

  /// Record a QR code generation event
  Future<void> trackGeneration({
    required String qrId,
    required String type, // 'user' or 'project'
    Map<String, dynamic>? metadata,
  }) async {
    await _recordEvent({
      'eventType': 'generation',
      'qrId': qrId,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    });
  }

  /// Record a QR code scan event
  Future<void> trackScan({
    required String qrId,
    required String type,
    required bool successful,
    Map<String, dynamic>? metadata,
  }) async {
    await _recordEvent({
      'eventType': 'scan',
      'qrId': qrId,
      'type': type,
      'successful': successful,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    });
  }

  /// Record a QR code share event
  Future<void> trackShare({
    required String qrId,
    required String method, // 'link', 'image', 'messaging'
    Map<String, dynamic>? metadata,
  }) async {
    await _recordEvent({
      'eventType': 'share',
      'qrId': qrId,
      'method': method,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    });
  }

  /// Record a QR code export event
  Future<void> trackExport({
    required String qrId,
    required String format, // 'png', 'jpg', etc.
    Map<String, dynamic>? metadata,
  }) async {
    await _recordEvent({
      'eventType': 'export',
      'qrId': qrId,
      'format': format,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    });
  }

  /// Record a QR code view event
  Future<void> trackView({
    required String qrId,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    await _recordEvent({
      'eventType': 'view',
      'qrId': qrId,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': metadata ?? {},
    });
  }

  /// Get analytics summary
  Future<QRAnalyticsSummary> getAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getAllEvents();
      
      // Filter by date range if provided
      final filteredEvents = events.where((event) {
        final timestamp = DateTime.parse(event['timestamp'] as String);
        if (startDate != null && timestamp.isBefore(startDate)) return false;
        if (endDate != null && timestamp.isAfter(endDate)) return false;
        return true;
      }).toList();

      // Calculate statistics
      final totalEvents = filteredEvents.length;
      final generations = filteredEvents.where((e) => e['eventType'] == 'generation').length;
      final scans = filteredEvents.where((e) => e['eventType'] == 'scan').length;
      final shares = filteredEvents.where((e) => e['eventType'] == 'share').length;
      final exports = filteredEvents.where((e) => e['eventType'] == 'export').length;
      final views = filteredEvents.where((e) => e['eventType'] == 'view').length;

      final successfulScans = filteredEvents
          .where((e) => e['eventType'] == 'scan' && e['successful'] == true)
          .length;
      final scanSuccessRate = scans > 0 ? (successfulScans / scans * 100).round() : 0;

      // Most popular QR codes
      final qrIdCounts = <String, int>{};
      for (final event in filteredEvents) {
        final qrId = event['qrId'] as String;
        qrIdCounts[qrId] = (qrIdCounts[qrId] ?? 0) + 1;
      }
      final popularQRs = qrIdCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Share methods breakdown
      final shareMethods = <String, int>{};
      for (final event in filteredEvents.where((e) => e['eventType'] == 'share')) {
        final method = event['method'] as String;
        shareMethods[method] = (shareMethods[method] ?? 0) + 1;
      }

      // Activity by day
      final activityByDay = <String, int>{};
      for (final event in filteredEvents) {
        final date = DateTime.parse(event['timestamp'] as String);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        activityByDay[dateKey] = (activityByDay[dateKey] ?? 0) + 1;
      }

      return QRAnalyticsSummary(
        totalEvents: totalEvents,
        totalGenerations: generations,
        totalScans: scans,
        totalShares: shares,
        totalExports: exports,
        totalViews: views,
        scanSuccessRate: scanSuccessRate,
        popularQRs: popularQRs.take(5).map((e) => {
          'qrId': e.key,
          'count': e.value,
        }).toList(),
        shareMethods: shareMethods,
        activityByDay: activityByDay,
      );
    } catch (e) {
      return QRAnalyticsSummary(
        totalEvents: 0,
        totalGenerations: 0,
        totalScans: 0,
        totalShares: 0,
        totalExports: 0,
        totalViews: 0,
        scanSuccessRate: 0,
        popularQRs: [],
        shareMethods: {},
        activityByDay: {},
      );
    }
  }

  /// Get analytics for a specific QR code
  Future<Map<String, dynamic>> getQRAnalytics(String qrId) async {
    try {
      final events = await _getAllEvents();
      final qrEvents = events.where((e) => e['qrId'] == qrId).toList();

      final scans = qrEvents.where((e) => e['eventType'] == 'scan').length;
      final shares = qrEvents.where((e) => e['eventType'] == 'share').length;
      final views = qrEvents.where((e) => e['eventType'] == 'view').length;

      return {
        'qrId': qrId,
        'totalEvents': qrEvents.length,
        'scans': scans,
        'shares': shares,
        'views': views,
        'lastActivity': qrEvents.isNotEmpty
            ? qrEvents.last['timestamp']
            : null,
      };
    } catch (e) {
      return {
        'qrId': qrId,
        'totalEvents': 0,
        'scans': 0,
        'shares': 0,
        'views': 0,
        'lastActivity': null,
      };
    }
  }

  /// Clear all analytics data
  Future<void> clearAnalytics() async {
    try {
      await _storage.delete(key: _analyticsKey);
    } catch (e) {
      throw Exception('Failed to clear analytics: $e');
    }
  }

  /// Export analytics data
  Future<String> exportAnalyticsAsJson() async {
    try {
      final events = await _getAllEvents();
      return json.encode({
        'exportedAt': DateTime.now().toIso8601String(),
        'totalEvents': events.length,
        'events': events,
      });
    } catch (e) {
      throw Exception('Failed to export analytics: $e');
    }
  }

  // Private helper methods

  Future<void> _recordEvent(Map<String, dynamic> event) async {
    try {
      final events = await _getAllEvents();
      events.add(event);
      await _saveEvents(events);
    } catch (e) {
      throw Exception('Failed to record event: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getAllEvents() async {
    try {
      final eventsJson = await _storage.read(key: _analyticsKey);
      if (eventsJson == null) return [];
      final List<dynamic> decoded = json.decode(eventsJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveEvents(List<Map<String, dynamic>> events) async {
    await _storage.write(key: _analyticsKey, value: json.encode(events));
  }
}

/// Summary of QR code analytics
class QRAnalyticsSummary {
  final int totalEvents;
  final int totalGenerations;
  final int totalScans;
  final int totalShares;
  final int totalExports;
  final int totalViews;
  final int scanSuccessRate;
  final List<Map<String, dynamic>> popularQRs;
  final Map<String, int> shareMethods;
  final Map<String, int> activityByDay;

  QRAnalyticsSummary({
    required this.totalEvents,
    required this.totalGenerations,
    required this.totalScans,
    required this.totalShares,
    required this.totalExports,
    required this.totalViews,
    required this.scanSuccessRate,
    required this.popularQRs,
    required this.shareMethods,
    required this.activityByDay,
  });

  Map<String, dynamic> toJson() => {
    'totalEvents': totalEvents,
    'totalGenerations': totalGenerations,
    'totalScans': totalScans,
    'totalShares': totalShares,
    'totalExports': totalExports,
    'totalViews': totalViews,
    'scanSuccessRate': scanSuccessRate,
    'popularQRs': popularQRs,
    'shareMethods': shareMethods,
    'activityByDay': activityByDay,
  };
}
