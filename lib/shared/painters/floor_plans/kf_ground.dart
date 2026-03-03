import 'package:flutter/material.dart';

class KFGroundFloorPainter extends CustomPainter {
  final bool darkMode;
  final String locale;

  KFGroundFloorPainter({this.darkMode = false, this.locale = 'en'});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale helper
    double sx(double pct) => pct / 100 * w;
    double sy(double pct) => pct / 100 * h;

    // Colors — Notion style
    final bgColor = darkMode ? const Color(0xFF191919) : const Color(0xFFF7F6F3);
    final wallColor = darkMode ? const Color(0xFF4A4A4A) : const Color(0xFFD1D0CC);
    final corridorColor = darkMode ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
    final roomFill = darkMode ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final textColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
    final doorColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

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

    // Main building outline
    canvas.drawRect(
      Rect.fromLTRB(sx(8), sy(15), sx(92), sy(85)),
      wallPaint,
    );

    // Main corridor (horizontal)
    canvas.drawRect(
      Rect.fromLTRB(sx(8), sy(42), sx(92), sy(58)),
      corridorPaint,
    );
    canvas.drawLine(Offset(sx(8), sy(42)), Offset(sx(92), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(8), sy(58)), Offset(sx(92), sy(58)), wallPaint);

    // Entrance area (left)
    canvas.drawRect(
      Rect.fromLTRB(sx(8), sy(42), sx(22), sy(58)),
      Paint()..color = (darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF)),
    );
    canvas.drawLine(Offset(sx(8), sy(44)), Offset(sx(8), sy(56)),
      Paint()..color = const Color(0xFF2EAADC)..strokeWidth = 4..strokeCap = StrokeCap.round);

    // Reception room
    canvas.drawRect(Rect.fromLTRB(sx(22), sy(42), sx(38), sy(58)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(22), sy(42), sx(38), sy(58)), wallPaint);
    // Door
    canvas.drawLine(Offset(sx(22), sy(48)), Offset(sx(22), sy(52)), doorPaint);

    // Radiology room
    canvas.drawRect(Rect.fromLTRB(sx(38), sy(58), sx(58), sy(75)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(38), sy(58), sx(58), sy(75)), wallPaint);
    canvas.drawLine(Offset(sx(45), sy(58)), Offset(sx(51), sy(58)), doorPaint);

    // Pharmacy room
    canvas.drawRect(Rect.fromLTRB(sx(65), sy(42), sx(85), sy(65)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(65), sy(42), sx(85), sy(65)), wallPaint);
    canvas.drawLine(Offset(sx(65), sy(50)), Offset(sx(65), sy(56)), doorPaint);

    // Emergency room (top-right)
    final erColor = darkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);
    canvas.drawRect(Rect.fromLTRB(sx(70), sy(15), sx(92), sy(42)), Paint()..color = erColor);
    canvas.drawRect(Rect.fromLTRB(sx(70), sy(15), sx(92), sy(42)), wallPaint);
    canvas.drawLine(Offset(sx(76), sy(42)), Offset(sx(84), sy(42)), doorPaint);

    // Upper rooms
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(35), sy(42)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(15), sx(35), sy(42)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(35), sy(15), sx(55), sy(42)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(35), sy(15), sx(55), sy(42)), wallPaint);

    // Lower rooms
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(38), sy(85)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(8), sy(58), sx(38), sy(85)), wallPaint);
    canvas.drawRect(Rect.fromLTRB(sx(58), sy(58), sx(92), sy(85)), roomPaint);
    canvas.drawRect(Rect.fromLTRB(sx(58), sy(58), sx(92), sy(85)), wallPaint);

    // Labels
    final textStyle = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);

    _drawLabel(canvas, locale == 'ar' ? 'الاستقبال' : 'Reception', Offset(sx(30), sy(50)), textStyle);
    _drawLabel(canvas, locale == 'ar' ? 'الأشعة' : 'Radiology', Offset(sx(48), sy(66)), textStyle);
    _drawLabel(canvas, locale == 'ar' ? 'الصيدلية' : 'Pharmacy', Offset(sx(75), sy(53)), textStyle);
    _drawLabel(canvas, locale == 'ar' ? 'الطوارئ' : 'Emergency', Offset(sx(81), sy(28)),
      textStyle.copyWith(color: const Color(0xFFEB5757), fontWeight: FontWeight.w700));
    _drawLabel(canvas, locale == 'ar' ? 'المدخل' : 'Entrance', Offset(sx(15), sy(50)),
      textStyle.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9));
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
  bool shouldRepaint(covariant KFGroundFloorPainter old) =>
      old.darkMode != darkMode || old.locale != locale;
}
