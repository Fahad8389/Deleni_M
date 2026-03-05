import 'package:flutter/material.dart';
import '../isometric_helper.dart';

class KFSecondFloorPainter extends CustomPainter with IsometricHelper {
  final bool darkMode;
  final String locale;

  KFSecondFloorPainter({this.darkMode = false, this.locale = 'en'});

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = darkMode ? const Color(0xFF191919) : const Color(0xFFF7F6F3);
    final wallColor = darkMode ? const Color(0xFF4A4A4A) : const Color(0xFFD1D0CC);
    final corridorColor = darkMode ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
    final roomFill = darkMode ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final textColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
    final doorColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);
    final clinicFill = darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF);
    final icuFill = darkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = bgColor);
    paintIsoDotGrid(canvas, size, darkMode);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    // Building outline
    drawIsoRoom(canvas, size, left: 3, top: 8, right: 97, bottom: 92,
      fill: Paint()..color = bgColor, stroke: wallPaint);

    // === BACK ROOMS X=82-97 ===
    drawIsoRoom(canvas, size, left: 82, top: 8, right: 97, bottom: 36,
      fill: Paint()..color = clinicFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 82, 16, 82, 28, doorPaint);

    drawIsoRoom(canvas, size, left: 82, top: 36, right: 97, bottom: 64,
      fill: Paint()..color = clinicFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 82, 42, 82, 58, doorPaint);

    drawIsoRoom(canvas, size, left: 82, top: 64, right: 97, bottom: 92,
      fill: Paint()..color = roomFill, stroke: wallPaint);

    // === CORRIDOR X=24-82 ===
    drawIsoCorridor(canvas, size, left: 24, top: 8, right: 82, bottom: 92,
      fill: Paint()..color = corridorColor, wallStroke: wallPaint);

    // ICU (in corridor, right side)
    drawIsoRoom(canvas, size, left: 55, top: 64, right: 75, bottom: 88,
      fill: Paint()..color = icuFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 55, 70, 55, 82, doorPaint);

    // Stairs
    paintIsoStairs(canvas, size, 52, 50, wallColor, corridorColor, textColor);

    // === FRONT ROOMS X=8-24 ===
    drawIsoRoom(canvas, size, left: 8, top: 8, right: 24, bottom: 36,
      fill: Paint()..color = roomFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 24, 16, 24, 28, doorPaint);

    drawIsoRoom(canvas, size, left: 8, top: 40, right: 24, bottom: 68,
      fill: Paint()..color = roomFill, stroke: wallPaint);
    drawIsoLine(canvas, size, 24, 48, 24, 60, doorPaint);

    drawIsoRoom(canvas, size, left: 8, top: 72, right: 24, bottom: 92,
      fill: Paint()..color = roomFill, stroke: wallPaint);

    // === ENTRANCE X=3-8 ===
    drawIsoRoom(canvas, size, left: 3, top: 36, right: 10, bottom: 64,
      fill: Paint()..color = (darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF)),
      stroke: wallPaint);
    drawIsoLine(canvas, size, 3, 40, 3, 60,
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Labels
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الأطفال' : 'Pediatrics', 90, 22, ts);
    drawIsoLabel(canvas, size, '203', 90, 30, ts.copyWith(fontSize: 8, color: textColor.withValues(alpha: 0.6)));
    drawIsoLabel(canvas, size, locale == 'ar' ? 'الجلدية' : 'Dermatology', 90, 50, ts);
    drawIsoLabel(canvas, size, '205', 90, 58, ts.copyWith(fontSize: 8, color: textColor.withValues(alpha: 0.6)));
    drawIsoLabel(canvas, size, locale == 'ar' ? 'العناية المركزة' : 'ICU', 65, 76,
      ts.copyWith(color: const Color(0xFFE65100), fontWeight: FontWeight.w700));
    drawIsoLabel(canvas, size, locale == 'ar' ? 'غرفة ٢٠١' : 'Room 201', 16, 22, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'غرفة ٢٠٢' : 'Room 202', 16, 54, ts);
    drawIsoLabel(canvas, size, locale == 'ar' ? 'المدخل' : 'Entrance', 6, 50,
      ts.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9));
  }

  @override
  bool shouldRepaint(covariant KFSecondFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
