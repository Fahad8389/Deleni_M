import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RCGroundFloorPainter extends CustomPainter {
  final bool darkMode;
  final String locale;

  RCGroundFloorPainter({this.darkMode = false, this.locale = 'en'});

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

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

    final wallPaint = Paint()..color = wallColor..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final doorPaint = Paint()..color = doorColor..strokeWidth = 3..strokeCap = StrokeCap.round;

    // Building outline (slightly different shape)
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

    // Emergency (top-right)
    final erColor = darkMode ? const Color(0xFF3D1F1F) : const Color(0xFFFEE2E2);
    canvas.drawRect(Rect.fromLTRB(sx(62), sy(18), sx(90), sy(42)), Paint()..color = erColor);
    canvas.drawRect(Rect.fromLTRB(sx(62), sy(18), sx(90), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(70), sy(42)), Offset(sx(78), sy(42)), doorPaint);

    // Laboratory (bottom)
    canvas.drawRect(Rect.fromLTRB(sx(45), sy(55), sx(72), sy(75)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(45), sy(55), sx(72), sy(75)), wallPaint);
    canvas.drawLine(Offset(sx(55), sy(55)), Offset(sx(63), sy(55)), doorPaint);

    // Other areas
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(18), sx(40), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(18), sx(40), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(40), sy(18), sx(62), sy(42)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(40), sy(18), sx(62), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(55), sx(45), sy(82)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(10), sy(55), sx(45), sy(82)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(72), sy(55), sx(90), sy(82)), Paint()..color = roomFill);
    canvas.drawRect(Rect.fromLTRB(sx(72), sy(55), sx(90), sy(82)), wallPaint);

    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    _drawLabel(canvas, locale == 'ar' ? 'الطوارئ' : 'Emergency', Offset(sx(76), sy(30)),
      ts.copyWith(color: AppColors.terracotta, fontWeight: FontWeight.w700));
    _drawLabel(canvas, locale == 'ar' ? 'المختبر' : 'Laboratory', Offset(sx(58), sy(65)), ts);
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
  bool shouldRepaint(covariant RCGroundFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
