import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RCFirstFloorPainter extends CustomPainter {
  final bool darkMode;
  final String locale;

  RCFirstFloorPainter({this.darkMode = false, this.locale = 'en'});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double sx(double pct) => pct / 100 * w;
    double sy(double pct) => pct / 100 * h;

    final bgColor = darkMode ? AppColors.midnightIndigo : const Color(0xFFF1F5F9);
    final wallColor = darkMode ? const Color(0xFF475569) : const Color(0xFF64748B);
    final corridorColor = darkMode ? const Color(0xFF0F172A) : Colors.white;
    final roomFill = darkMode ? AppColors.darkSurface : const Color(0xFFF8FAFC);
    final textColor = darkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final doorColor = darkMode ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1);
    final clinicFill = darkMode ? const Color(0xFF1A3333) : const Color(0xFFE0F7FA);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromLTRB(sx(10), sy(18), sx(90), sy(82)), wallPaint);

    // Corridor
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(42), sx(90), sy(55)), Paint()..color = corridorColor);
    canvas.drawLine(Offset(sx(10), sy(42)), Offset(sx(90), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(10), sy(55)), Offset(sx(90), sy(55)), wallPaint);

    // Entrance
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(42), sx(28), sy(55)),
      Paint()..color = (darkMode ? const Color(0xFF1E3A3A) : const Color(0xFFE0F2FE)));
    canvas.drawLine(Offset(sx(10), sy(44)), Offset(sx(10), sy(53)),
      Paint()..color = AppColors.deepTeal..strokeWidth = 4..strokeCap = StrokeCap.round);

    // ENT Clinic (top-center)
    canvas.drawRect(Rect.fromLTRB(sx(38), sy(18), sx(62), sy(42)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(38), sy(18), sx(62), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(46), sy(42)), Offset(sx(54), sy(42)), doorPaint);

    // Ophthalmology Clinic (top-right)
    canvas.drawRect(Rect.fromLTRB(sx(58), sy(18), sx(82), sy(48)), Paint()..color = clinicFill);
    canvas.drawRect(Rect.fromLTRB(sx(58), sy(18), sx(82), sy(48)), wallPaint);
    canvas.drawLine(Offset(sx(66), sy(48)), Offset(sx(74), sy(48)), doorPaint);

    // Fill areas
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(18), sx(38), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(18), sx(38), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(82), sy(18), sx(90), sy(48)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(82), sy(18), sx(90), sy(48)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(55), sx(50), sy(82)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(55), sx(50), sy(82)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(50), sy(55), sx(90), sy(82)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(50), sy(55), sx(90), sy(82)), wallPaint);

    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    _drawLabel(canvas, locale == 'ar' ? 'أنف وأذن' : 'ENT', Offset(sx(50), sy(28)), ts);
    _drawLabel(canvas, '112', Offset(sx(50), sy(35)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'العيون' : 'Ophthalmology', Offset(sx(70), sy(30)), ts);
    _drawLabel(canvas, '115', Offset(sx(70), sy(38)), ts.copyWith(fontSize: 8, color: textColor.withOpacity(0.6)));
    _drawLabel(canvas, locale == 'ar' ? 'المدخل' : 'Entrance', Offset(sx(19), sy(48)),
      ts.copyWith(color: AppColors.deepTeal, fontWeight: FontWeight.w700, fontSize: 9));
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
  bool shouldRepaint(covariant RCFirstFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
