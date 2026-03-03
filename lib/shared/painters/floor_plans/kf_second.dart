import 'package:flutter/material.dart';

class KFSecondFloorPainter extends CustomPainter {
  final bool darkMode;
  final String locale;

  KFSecondFloorPainter({this.darkMode = false, this.locale = 'en'});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double sx(double pct) => pct / 100 * w;
    double sy(double pct) => pct / 100 * h;

    final bgColor = darkMode ? const Color(0xFF191919) : const Color(0xFFF7F6F3);
    final wallColor = darkMode ? const Color(0xFF4A4A4A) : const Color(0xFFD1D0CC);
    final corridorColor = darkMode ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
    final roomFill = darkMode ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final textColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
    final doorColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);
    final clinicFill = darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF);
    final icuFill = darkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    // Building outline
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(92), sy(85)), wallPaint);

    // Main corridor
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(42), sx(92), sy(58)), Paint()..color = corridorColor);
    canvas.drawLine(Offset(sx(8), sy(42)), Offset(sx(92), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(8), sy(58)), Offset(sx(92), sy(58)), wallPaint);

    // Entrance
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(42), sx(22), sy(58)),
      Paint()..color = (darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF)));
    canvas.drawLine(Offset(sx(8), sy(44)), Offset(sx(8), sy(56)),
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Pediatrics (top-left)
    canvas.drawRect(Rect.fromLTRB(sx(32), sy(15), sx(56), sy(42)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(32), sy(15), sx(56), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(40), sy(42)), Offset(sx(48), sy(42)), doorPaint);

    // Dermatology (top-right)
    canvas.drawRect(Rect.fromLTRB(sx(56), sy(15), sx(76), sy(42)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(56), sy(15), sx(76), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(62), sy(42)), Offset(sx(70), sy(42)), doorPaint);

    // ICU (right)
    canvas.drawRect(Rect.fromLTRB(sx(70), sy(42), sx(92), sy(60)), Paint()..color = icuFill);
    canvas.drawRect(Rect.fromLTRB(sx(70), sy(42), sx(92), sy(60)), wallPaint);
    canvas.drawLine(Offset(sx(70), sy(47)), Offset(sx(70), sy(55)), doorPaint);

    // Room 201
    canvas.drawRect(Rect.fromLTRB(sx(28), sy(58), sx(50), sy(78)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(28), sy(58), sx(50), sy(78)), wallPaint);
    canvas.drawLine(Offset(sx(35), sy(58)), Offset(sx(43), sy(58)), doorPaint);

    // Room 202
    canvas.drawRect(Rect.fromLTRB(sx(50), sy(58), sx(68), sy(78)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(50), sy(58), sx(68), sy(78)), wallPaint);
    canvas.drawLine(Offset(sx(55), sy(58)), Offset(sx(61), sy(58)), doorPaint);

    // Fill areas
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(32), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(32), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(76), sy(15), sx(92), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(76), sy(15), sx(92), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(28), sy(85)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(28), sy(85)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(68), sy(60), sx(92), sy(85)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(68), sy(60), sx(92), sy(85)), wallPaint);

    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    _drawLabel(canvas, locale == 'ar' ? 'الأطفال' : 'Pediatrics', Offset(sx(44), sy(25)), ts);
    _drawLabel(canvas, '203', Offset(sx(44), sy(33)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'الجلدية' : 'Dermatology', Offset(sx(66), sy(25)), ts);
    _drawLabel(canvas, '205', Offset(sx(66), sy(33)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'العناية المركزة' : 'ICU', Offset(sx(81), sy(50)),
      ts.copyWith(color: const Color(0xFFE65100), fontWeight: FontWeight.w700));
    _drawLabel(canvas, locale == 'ar' ? 'غرفة ٢٠١' : 'Room 201', Offset(sx(39), sy(68)), ts);
    _drawLabel(canvas, locale == 'ar' ? 'غرفة ٢٠٢' : 'Room 202', Offset(sx(59), sy(68)), ts);
    _drawLabel(canvas, locale == 'ar' ? 'المدخل' : 'Entrance', Offset(sx(15), sy(50)),
      ts.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9));
  }

  void _drawLabel(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant KFSecondFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
