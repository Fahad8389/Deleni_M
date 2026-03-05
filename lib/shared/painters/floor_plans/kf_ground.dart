import 'package:flutter/material.dart';
import '../isometric_helper.dart';

class KFGroundFloorPainter extends CustomPainter with IsometricHelper {
  final bool darkMode;
  final String locale;

  KFGroundFloorPainter({this.darkMode = false, this.locale = 'en'});

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

    final wallPaint = Paint()
      ..color = wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final roomPaint = Paint()..color = roomFill;
    final corridorPaint = Paint()..color = corridorColor;
    final doorPaint = Paint()
      ..color = doorColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Building outline
    drawIsoRoom(canvas, size,
      left: 3, top: 8, right: 97, bottom: 92,
      fill: Paint()..color = bgColor, stroke: wallPaint);

    // === BACK ROOMS (far from entrance, top of screen) X=82-97 ===
    drawIsoRoom(canvas, size,
      left: 82, top: 8, right: 97, bottom: 36,
      fill: roomPaint, stroke: wallPaint);

    final erColor = darkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);
    drawIsoRoom(canvas, size,
      left: 82, top: 36, right: 97, bottom: 64,
      fill: Paint()..color = erColor, stroke: wallPaint);
    drawIsoLine(canvas, size, 82, 42, 82, 58, doorPaint);

    drawIsoRoom(canvas, size,
      left: 82, top: 64, right: 97, bottom: 92,
      fill: roomPaint, stroke: wallPaint);

    // === CORRIDOR (wide road between rooms) X=24-82 ===
    drawIsoCorridor(canvas, size,
      left: 24, top: 8, right: 82, bottom: 92,
      fill: corridorPaint, wallStroke: wallPaint);

    // Reception (room in corridor, near entrance)
    drawIsoRoom(canvas, size,
      left: 24, top: 36, right: 40, bottom: 64,
      fill: roomPaint, stroke: wallPaint);
    drawIsoLine(canvas, size, 40, 44, 40, 56, doorPaint);

    // Pharmacy (room in corridor, far side)
    drawIsoRoom(canvas, size,
      left: 60, top: 64, right: 82, bottom: 85,
      fill: roomPaint, stroke: wallPaint);
    drawIsoLine(canvas, size, 60, 70, 60, 80, doorPaint);

    // Stairs
    paintIsoStairs(canvas, size, 52, 50, wallColor, corridorColor, textColor);

    // === FRONT ROOMS (near entrance, bottom of screen) X=8-24 ===
    drawIsoRoom(canvas, size,
      left: 8, top: 8, right: 24, bottom: 36,
      fill: roomPaint, stroke: wallPaint);

    drawIsoRoom(canvas, size,
      left: 8, top: 40, right: 24, bottom: 68,
      fill: roomPaint, stroke: wallPaint);
    drawIsoLine(canvas, size, 24, 48, 24, 60, doorPaint);

    drawIsoRoom(canvas, size,
      left: 8, top: 72, right: 24, bottom: 92,
      fill: roomPaint, stroke: wallPaint);

    // === ENTRANCE (very bottom) X=3-8 ===
    final entranceColor = darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF);
    drawIsoRoom(canvas, size,
      left: 3, top: 36, right: 10, bottom: 64,
      fill: Paint()..color = entranceColor, stroke: wallPaint);
    drawIsoLine(canvas, size, 3, 40, 3, 60,
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Labels
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الطوارئ' : 'Emergency', 90, 50,
      ts.copyWith(color: const Color(0xFFEB5757), fontWeight: FontWeight.w700));
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الصيدلية' : 'Pharmacy', 71, 75, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الاستقبال' : 'Reception', 32, 50, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الأشعة' : 'Radiology', 16, 54, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'المدخل' : 'Entrance', 6, 50,
      ts.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9));
  }

  @override
  bool shouldRepaint(covariant KFGroundFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
