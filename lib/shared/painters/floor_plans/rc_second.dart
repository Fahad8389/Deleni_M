import 'package:flutter/material.dart';
import '../isometric_helper.dart';

class RCSecondFloorPainter extends CustomPainter with IsometricHelper {
  final bool darkMode;
  final String locale;

  RCSecondFloorPainter({this.darkMode = false, this.locale = 'en'});

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = darkMode ? const Color(0xFF191919) : const Color(0xFFF7F6F3);
    final wallColor = darkMode ? const Color(0xFF4A4A4A) : const Color(0xFFD1D0CC);
    final corridorColor = darkMode ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
    final roomFill = darkMode ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final textColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
    final doorColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgColor);
    paintIsoDotGrid(canvas, size, darkMode);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    // Building outline
    drawIsoRoom(canvas, size, left: 3, top: 10, right: 97, bottom: 90,
      fill: Paint()..color = bgColor, stroke: wallPaint);

    // === BACK ROOMS X=80-97 ===
    final surgeryFill = darkMode ? const Color(0xFF2A2040) : const Color(0xFFEDE7F6);
    drawIsoRoom(canvas, size, left: 80, top: 10, right: 97, bottom: 50,
      fill: Paint()..color = surgeryFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 80, 25, 80, 40, doorPaint);

    drawIsoRoom(canvas, size, left: 80, top: 50, right: 97, bottom: 90,
      fill: Paint()..color = roomFill, stroke: wallPaint);

    // === CORRIDOR X=26-80 ===
    drawIsoCorridor(canvas, size, left: 26, top: 10, right: 80, bottom: 90,
      fill: Paint()..color = corridorColor, wallStroke: wallPaint);

    // Stairs
    paintIsoStairs(canvas, size, 52, 50, wallColor, corridorColor, textColor);

    // === FRONT ROOMS X=10-26 ===
    drawIsoRoom(canvas, size, left: 10, top: 10, right: 26, bottom: 50,
      fill: Paint()..color = roomFill, stroke: wallPaint);
    drawIsoRoom(canvas, size, left: 10, top: 50, right: 26, bottom: 90,
      fill: Paint()..color = roomFill, stroke: wallPaint);

    // === ENTRANCE X=3-10 ===
    drawIsoRoom(canvas, size, left: 3, top: 36, right: 10, bottom: 64,
      fill: Paint()..color = (darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF)),
      stroke: wallPaint);
    drawIsoLine(canvas, size, 3, 40, 3, 60,
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Labels
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الجراحة' : 'Surgery', 88, 30, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'المدخل' : 'Entrance', 6, 50,
      ts.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9));
  }

  @override
  bool shouldRepaint(covariant RCSecondFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
