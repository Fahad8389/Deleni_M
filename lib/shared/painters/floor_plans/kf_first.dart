import 'package:flutter/material.dart';

class KFFirstFloorPainter extends CustomPainter {
  final bool darkMode;
  final String locale;

  KFFirstFloorPainter({this.darkMode = false, this.locale = 'en'});

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

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    // Building outline
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(92), sy(85)), wallPaint);

    // Main corridor
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(42), sx(92), sy(58)), Paint()..color = corridorColor);
    canvas.drawLine(Offset(sx(8), sy(42)), Offset(sx(92), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(8), sy(58)), Offset(sx(92), sy(58)), wallPaint);

    // Entrance area
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(42), sx(22), sy(58)),
      Paint()..color = (darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF)));
    canvas.drawLine(Offset(sx(8), sy(44)), Offset(sx(8), sy(56)),
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Cardiology clinic (top-left area)
    canvas.drawRect(Rect.fromLTRB(sx(28), sy(15), sx(52), sy(42)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(28), sy(15), sx(52), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(36), sy(42)), Offset(sx(44), sy(42)), doorPaint);

    // Neurology clinic (top-center)
    canvas.drawRect(Rect.fromLTRB(sx(52), sy(15), sx(72), sy(42)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(52), sy(15), sx(72), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(58), sy(42)), Offset(sx(66), sy(42)), doorPaint);

    // Orthopedics clinic (right)
    canvas.drawRect(Rect.fromLTRB(sx(65), sy(42), sx(88), sy(58)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(65), sy(42), sx(88), sy(58)), wallPaint);
    canvas.drawLine(Offset(sx(65), sy(47)), Offset(sx(65), sy(53)), doorPaint);

    // Room 101 (bottom-left)
    canvas.drawRect(Rect.fromLTRB(sx(25), sy(58), sx(45), sy(80)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(25), sy(58), sx(45), sy(80)), wallPaint);
    canvas.drawLine(Offset(sx(32), sy(58)), Offset(sx(38), sy(58)), doorPaint);

    // Room 102 (bottom-center)
    canvas.drawRect(Rect.fromLTRB(sx(45), sy(58), sx(62), sy(80)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(45), sy(58), sx(62), sy(80)), wallPaint);
    canvas.drawLine(Offset(sx(50), sy(58)), Offset(sx(56), sy(58)), doorPaint);

    // Remaining areas
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(28), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(28), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(72), sy(15), sx(92), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(72), sy(15), sx(92), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(25), sy(85)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(25), sy(85)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(62), sy(58), sx(92), sy(85)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(62), sy(58), sx(92), sy(85)), wallPaint);

    // Labels
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    _drawLabel(canvas, locale == 'ar' ? 'القلب' : 'Cardiology', Offset(sx(40), sy(28)), ts);
    _drawLabel(canvas, '105', Offset(sx(40), sy(35)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'الأعصاب' : 'Neurology', Offset(sx(62), sy(28)), ts);
    _drawLabel(canvas, '108', Offset(sx(62), sy(35)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'العظام' : 'Orthopedics', Offset(sx(76), sy(50)), ts);
    _drawLabel(canvas, '110', Offset(sx(76), sy(54)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'غرفة ١٠١' : 'Room 101', Offset(sx(35), sy(69)), ts);
    _drawLabel(canvas, locale == 'ar' ? 'غرفة ١٠٢' : 'Room 102', Offset(sx(53), sy(69)), ts);
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
  bool shouldRepaint(covariant KFFirstFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
