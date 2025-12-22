import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/qr_scan_service.dart';
import '../services/qr_generation_service.dart';
import '../services/qr_cache_service.dart';
import '../services/qr_analytics_service.dart';

/// Provider for QR scanning service
final qrScanServiceProvider = Provider<QRScanService>((ref) {
  final service = QRScanService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for QR generation service
final qrGenerationServiceProvider = Provider<QRGenerationService>((ref) {
  return QRGenerationService();
});

/// Provider for QR cache service
/// Handles offline caching of QR codes and scan queue
final qrCacheServiceProvider = Provider<QRCacheService>((ref) {
  return QRCacheService();
});

/// Provider for QR analytics service
/// Tracks and analyzes QR code usage statistics
final qrAnalyticsServiceProvider = Provider<QRAnalyticsService>((ref) {
  return QRAnalyticsService();
});

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code App',
      home: QRHomePage(),
    );
  }
}

class QRHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final qrScanService = watch(qrScanServiceProvider);
    final qrGenerationService = watch(qrGenerationServiceProvider);
    final qrCacheService = watch(qrCacheServiceProvider);
    final qrAnalyticsService = watch(qrAnalyticsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to QR scan page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanPage()),
                );
              },
              child: Text('Scan QR Code'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to QR generation page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRGenerationPage()),
                );
              },
              child: Text('Generate QR Code'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to QR cache page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRCashPage()),
                );
              },
              child: Text('View Cached QR Codes'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to QR analytics page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRAnalyticsPage()),
                );
              },
              child: Text('View QR Code Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Center(
        child: Text('QR Scan Page'),
      ),
    );
  }
}

class QRGenerationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate QR Code'),
      },
      body: Center(
        child: Text('QR Generation Page'),
      ),
    );
  }
}

class QRCashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Cached QR Codes'),
      },
      body: Center(
        child: Text('QR Cache Page'),
      ),
    );
  }
}

class QRAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View QR Code Analytics'),
      },
      body: Center(
        child: Text('QR Analytics Page'),
      ),
    );
  }
}
