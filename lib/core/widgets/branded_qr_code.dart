import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/tokens.dart';

/// A customizable QR code widget with app branding, theme colors, and export capability
class BrandedQRCode extends StatefulWidget {
  const BrandedQRCode({
    super.key,
    required this.data,
    this.size = 250.0,
    this.showLogo = true,
    this.backgroundColor,
    this.foregroundColor,
    this.logoSize = 60.0,
    this.padding = 16.0,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
  });

  final String data;
  final double size;
  final bool showLogo;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double logoSize;
  final double padding;
  final double borderRadius;
  final double elevation;

  @override
  State<BrandedQRCode> createState() => _BrandedQRCodeState();
}

class _BrandedQRCodeState extends State<BrandedQRCode> {
  final GlobalKey _qrKey = GlobalKey();

  /// Export the QR code as an image
  Future<Uint8List?> exportAsImage() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error exporting QR code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? Colors.white;
    final fgColor = widget.foregroundColor ?? Colors.black;

    return RepaintBoundary(
      key: _qrKey,
      child: Material(
        elevation: widget.elevation,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          padding: EdgeInsets.all(widget.padding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR Code with optional logo
              QrImageView(
                data: widget.data,
                version: QrVersions.auto,
                size: widget.size,
                backgroundColor: bgColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: fgColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: fgColor,
                ),
                embeddedImage: widget.showLogo ? _buildLogoImage() : null,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(widget.logoSize, widget.logoSize),
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.H, // High error correction for logo
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _buildLogoImage() {
    // Use a custom logo widget that renders as an image
    // For now, we'll use null and let the QR code be plain
    // You can replace this with an actual logo asset
    return null;
  }
}

/// Controller for managing QR code operations
class BrandedQRController {
  final GlobalKey<_BrandedQRCodeState>? _key;

  BrandedQRController([this._key]);

  Future<Uint8List?> exportAsImage() async {
    return await _key?.currentState?.exportAsImage();
  }
}

/// Extension to create a controller-aware BrandedQRCode
class BrandedQRCodeWithController extends StatelessWidget {
  const BrandedQRCodeWithController({
    super.key,
    required this.data,
    required this.controller,
    this.size = 250.0,
    this.showLogo = true,
    this.backgroundColor,
    this.foregroundColor,
    this.logoSize = 60.0,
    this.padding = 16.0,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
  });

  final String data;
  final BrandedQRController controller;
  final double size;
  final bool showLogo;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double logoSize;
  final double padding;
  final double borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<_BrandedQRCodeState>();
    // Connect the controller to the key
    if (controller._key != key) {
      // This is a simplified approach; in production, you'd use a proper state management
    }

    return BrandedQRCode(
      key: key,
      data: data,
      size: size,
      showLogo: showLogo,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      logoSize: logoSize,
      padding: padding,
      borderRadius: borderRadius,
      elevation: elevation,
    );
  }
}

/// Preset QR code styles
class QRCodeStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final String name;

  const QRCodeStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.name,
  });

  static const classic = QRCodeStyle(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    name: 'Classic',
  );

  static const branded = QRCodeStyle(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primary,
    name: 'Branded',
  );

  static const dark = QRCodeStyle(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    name: 'Dark',
  );

  static const ocean = QRCodeStyle(
    backgroundColor: Color(0xFFE3F2FD),
    foregroundColor: Color(0xFF0D47A1),
    name: 'Ocean',
  );

  static const forest = QRCodeStyle(
    backgroundColor: Color(0xFFE8F5E9),
    foregroundColor: Color(0xFF1B5E20),
    name: 'Forest',
  );

  static const sunset = QRCodeStyle(
    backgroundColor: Color(0xFFFFF3E0),
    foregroundColor: Color(0xFFE65100),
    name: 'Sunset',
  );

  static const List<QRCodeStyle> presets = [
    classic,
    branded,
    dark,
    ocean,
    forest,
    sunset,
  ];
}
