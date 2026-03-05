import 'package:flutter/material.dart';

/// Mixin providing Google Maps–style tilted 2D coordinate transform.
/// Entrance (low X) is at the bottom (near the viewer), far end (high X)
/// at top (further away). Subtle perspective tilt like Google Maps.
mixin IsometricHelper {
  /// Convert percentage coords (0-100) to screen coordinates.
  /// X axis = depth (low X near viewer at bottom, high X far away at top).
  /// Y axis = lateral (left to right).
  /// Maintains natural proportions (max 1.5× width for height).
  Offset toIso(double pctX, double pctY, Size size) {
    final lateral = pctY / 100.0;
    final depth = pctX / 100.0;

    const margin = 0.02;
    final availW = size.width * (1 - 2 * margin);
    final availH = size.height * (1 - 2 * margin);
    final vOffset = size.height * margin;

    // Subtle Google Maps tilt: things further away are slightly narrower
    const nearScale = 1.0;
    const farScale = 0.88;
    final rowScale = nearScale + (farScale - nearScale) * depth;
    final rowWidth = availW * rowScale;
    final rowLeft = size.width * margin + (availW - rowWidth) / 2;

    final screenX = rowLeft + lateral * rowWidth;
    final screenY = vOffset + availH - depth * availH;

    return Offset(screenX, screenY);
  }

  /// Wall height — not used in flat mode, returns 0.
  double wallHeight(Size size) => 0;

  /// Draw a flat room (filled polygon in map coordinates).
  void drawIsoRoom(
    Canvas canvas,
    Size size, {
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Paint fill,
    required Paint stroke,
    double? wallH,
  }) {
    final tl = toIso(left, top, size);
    final tr = toIso(right, top, size);
    final br = toIso(right, bottom, size);
    final bl = toIso(left, bottom, size);

    final path = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  /// Draw a corridor (floor fill with top/bottom wall lines only).
  void drawIsoCorridor(
    Canvas canvas,
    Size size, {
    required double left,
    required double top,
    required double right,
    required double bottom,
    required Paint fill,
    required Paint wallStroke,
  }) {
    final tl = toIso(left, top, size);
    final tr = toIso(right, top, size);
    final br = toIso(right, bottom, size);
    final bl = toIso(left, bottom, size);

    final path = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close();
    canvas.drawPath(path, fill);

    drawIsoLine(canvas, size, left, top, right, top, wallStroke);
    drawIsoLine(canvas, size, left, bottom, right, bottom, wallStroke);
  }

  /// Draw a line in map space.
  void drawIsoLine(
    Canvas canvas,
    Size size,
    double x1,
    double y1,
    double x2,
    double y2,
    Paint paint,
  ) {
    canvas.drawLine(toIso(x1, y1, size), toIso(x2, y2, size), paint);
  }

  /// Draw a label at a map position.
  void drawIsoLabel(
    Canvas canvas,
    Size size,
    String text,
    double pctX,
    double pctY,
    TextStyle style,
  ) {
    final pos = toIso(pctX, pctY, size);
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  /// Draw dot grid background.
  void paintIsoDotGrid(Canvas canvas, Size size, bool darkMode) {
    final dotColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);
    final dotPaint = Paint()..color = dotColor;
    const spacing = 5.0;

    for (double x = 0; x <= 100; x += spacing) {
      for (double y = 0; y <= 100; y += spacing) {
        final pt = toIso(x, y, size);
        canvas.drawCircle(pt, 0.8, dotPaint);
      }
    }
  }

  /// Draw stairs marker.
  void paintIsoStairs(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    Color wallColor,
    Color fillColor,
    Color textColor,
  ) {
    const halfSize = 3.0;
    drawIsoRoom(
      canvas,
      size,
      left: cx - halfSize,
      top: cy - halfSize,
      right: cx + halfSize,
      bottom: cy + halfSize,
      fill: Paint()..color = fillColor,
      stroke: Paint()
        ..color = wallColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final stepPaint = Paint()
      ..color = wallColor
      ..strokeWidth = 0.8;
    for (var i = 0; i < 4; i++) {
      final frac = (i + 1) / 5.0;
      final y = cy - halfSize + halfSize * 2 * frac;
      drawIsoLine(canvas, size, cx - halfSize * 0.6, y, cx + halfSize * 0.6, y, stepPaint);
    }

    drawIsoLabel(
      canvas,
      size,
      '↕',
      cx + halfSize * 0.8,
      cy,
      TextStyle(color: textColor, fontSize: 8, fontWeight: FontWeight.w600),
    );
  }
}
