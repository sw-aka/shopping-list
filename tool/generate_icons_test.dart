// Manual only, outside the normal test suite; overwrites icon and splash assets.
// Run with:
//
//   flutter test tool/generate_icons_test.dart
//
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _mintDark = Color(0xFF256B4D);
const _mintLight = Color(0xFF37936C);
const _mint = Color(0xFF2E7D5B);

void _drawCheck(Canvas canvas, double size, Color color, double strokeScale) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * strokeScale
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final path = Path()
    ..moveTo(size * 0.30, size * 0.53)
    ..lineTo(size * 0.445, size * 0.675)
    ..lineTo(size * 0.72, size * 0.36);
  canvas.drawPath(path, paint);
}

void _drawGradient(Canvas canvas, double size, {double radius = 0}) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  final paint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_mintLight, _mintDark],
    ).createShader(rect);
  if (radius > 0) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)), paint);
  } else {
    canvas.drawRect(rect, paint);
  }
}

Future<void> _savePng(
    String path, double size, void Function(Canvas canvas) draw) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  draw(canvas);
  final image =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
  debugPrint('wrote $path');
}

void main() {
  test('generate launcher and splash images', () async {
    const s = 1024.0;

    await _savePng('assets/icon/icon.png', s, (canvas) {
      _drawGradient(canvas, s, radius: s * 0.18);
      _drawCheck(canvas, s, Colors.white, 0.105);
    });

    await _savePng('assets/icon/icon_foreground.png', s, (canvas) {
      canvas
        ..translate(s / 2, s / 2)
        // Shrink the foreground into the adaptive icon safe zone.
        ..scale(0.58)
        ..translate(-s / 2, -s / 2);
      _drawCheck(canvas, s, Colors.white, 0.105);
    });

    await _savePng('assets/icon/icon_background.png', s, (canvas) {
      _drawGradient(canvas, s);
    });

    // These PNGs are for the pre-Android-12 launch screen.
    const splash = 512.0;
    await _savePng(
        'android/app/src/main/res/drawable-nodpi/splash_check.png', splash,
        (canvas) => _drawCheck(canvas, splash, _mint, 0.10));
    await _savePng(
        'android/app/src/main/res/drawable-night-nodpi/splash_check.png',
        splash,
        (canvas) => _drawCheck(canvas, splash, const Color(0xFF8ED0B4), 0.10));
  });
}
