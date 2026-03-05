import 'package:flutter/material.dart';
import '../isometric_helper.dart';
import '../../../data/models/generated_floor_plan.dart';

class GeneratedFloorPlanPainter extends CustomPainter with IsometricHelper {
  final GeneratedFloorPlan floorPlan;
  final bool darkMode;
  final String locale;

  GeneratedFloorPlanPainter({
    required this.floorPlan,
    this.darkMode = false,
    this.locale = 'en',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = darkMode ? const Color(0xFF191919) : const Color(0xFFF7F6F3);
    final wallColor = darkMode ? const Color(0xFF4A4A4A) : const Color(0xFFD1D0CC);
    final corridorColor = darkMode ? const Color(0xFF202020) : const Color(0xFFFFFFFF);
    final roomFill = darkMode ? const Color(0xFF252525) : const Color(0xFFFFFFFF);
    final textColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
    final doorColor = darkMode ? const Color(0xFF363636) : const Color(0xFFE3E2DE);
    final clinicFill = darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF);
    final erColor = darkMode ? const Color(0xFF3D2020) : const Color(0xFFFFE2DD);
    final entranceColor = darkMode ? const Color(0xFF1E3040) : const Color(0xFFD3E5EF);

    final wallPaint = Paint()
      ..color = wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final doorPaint = Paint()
      ..color = doorColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 1. Background + dot grid
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );
    paintIsoDotGrid(canvas, size, darkMode);

    // 2. Building outline
    drawIsoRoom(canvas, size,
      left: floorPlan.buildingLeft,
      top: floorPlan.buildingTop,
      right: floorPlan.buildingRight,
      bottom: floorPlan.buildingBottom,
      fill: Paint()..color = bgColor,
      stroke: wallPaint,
    );

    // 3. Back rooms (high X = far from viewer, drawn first)
    for (final room in floorPlan.rooms.where((r) => r.left >= floorPlan.corridorRight)) {
      _drawRoom(canvas, size, room, wallPaint, doorPaint, textColor,
        roomFill, clinicFill, erColor, entranceColor);
    }

    // 4. Corridor
    drawIsoCorridor(canvas, size,
      left: floorPlan.corridorLeft,
      top: floorPlan.corridorTop,
      right: floorPlan.corridorRight,
      bottom: floorPlan.corridorBottom,
      fill: Paint()..color = corridorColor,
      wallStroke: wallPaint,
    );

    // 5. Stairs
    paintIsoStairs(canvas, size, floorPlan.stairsX, floorPlan.stairsY,
      wallColor, corridorColor, textColor);

    // 6. Rooms inside corridor
    for (final room in floorPlan.rooms.where((r) =>
        r.left >= floorPlan.corridorLeft && r.left < floorPlan.corridorRight)) {
      _drawRoom(canvas, size, room, wallPaint, doorPaint, textColor,
        roomFill, clinicFill, erColor, entranceColor);
    }

    // 7. Front rooms (low X = near viewer, drawn last)
    for (final room in floorPlan.rooms.where((r) => r.left < floorPlan.corridorLeft)) {
      _drawRoom(canvas, size, room, wallPaint, doorPaint, textColor,
        roomFill, clinicFill, erColor, entranceColor);
    }

    // 8. Entrance area
    drawIsoRoom(canvas, size,
      left: floorPlan.entranceX - 3,
      top: floorPlan.entranceY - 14,
      right: floorPlan.entranceX + 3,
      bottom: floorPlan.entranceY + 14,
      fill: Paint()..color = entranceColor,
      stroke: wallPaint,
    );
    drawIsoLine(canvas, size,
      floorPlan.entranceX - 4, floorPlan.entranceY - 10,
      floorPlan.entranceX - 4, floorPlan.entranceY + 10,
      Paint()
        ..color = const Color(0xFF2EAADC)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // 9. Entrance label
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);
    drawIsoLabel(canvas, size,
      locale == 'ar' ? 'المدخل' : 'Entrance',
      floorPlan.entranceX, floorPlan.entranceY,
      ts.copyWith(color: const Color(0xFF2EAADC), fontWeight: FontWeight.w700, fontSize: 9),
    );
  }

  void _drawRoom(
    Canvas canvas,
    Size size,
    GeneratedRoom room,
    Paint wallPaint,
    Paint doorPaint,
    Color textColor,
    Color roomFill,
    Color clinicFill,
    Color erColor,
    Color entranceColor,
  ) {
    final fill = switch (room.fillType) {
      'clinic' => clinicFill,
      'emergency' => erColor,
      'entrance' => entranceColor,
      _ => roomFill,
    };

    drawIsoRoom(canvas, size,
      left: room.left, top: room.top,
      right: room.right, bottom: room.bottom,
      fill: Paint()..color = fill, stroke: wallPaint,
    );

    // Door
    _drawDoor(canvas, size, room, doorPaint);

    // Label
    final label = locale == 'ar' ? room.nameAr : room.nameEn;
    final ts = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500);

    if (room.type == 'emergency') {
      drawIsoLabel(canvas, size, label, room.positionX, room.positionY,
        ts.copyWith(color: const Color(0xFFEB5757), fontWeight: FontWeight.w700));
    } else {
      drawIsoLabel(canvas, size, label, room.positionX, room.positionY, ts);
    }

    // Room number
    if (room.roomNumber != null) {
      drawIsoLabel(canvas, size, room.roomNumber!, room.positionX, room.positionY + 8,
        ts.copyWith(fontSize: 8, color: textColor.withValues(alpha: 0.6)));
    }
  }

  void _drawDoor(Canvas canvas, Size size, GeneratedRoom room, Paint doorPaint) {
    switch (room.doorWall) {
      case 'left':
        final yStart = room.top + (room.bottom - room.top) * room.doorStart / 100;
        final yEnd = room.top + (room.bottom - room.top) * room.doorEnd / 100;
        drawIsoLine(canvas, size, room.left, yStart, room.left, yEnd, doorPaint);
      case 'right':
        final yStart = room.top + (room.bottom - room.top) * room.doorStart / 100;
        final yEnd = room.top + (room.bottom - room.top) * room.doorEnd / 100;
        drawIsoLine(canvas, size, room.right, yStart, room.right, yEnd, doorPaint);
      case 'top':
        final xStart = room.left + (room.right - room.left) * room.doorStart / 100;
        final xEnd = room.left + (room.right - room.left) * room.doorEnd / 100;
        drawIsoLine(canvas, size, xStart, room.top, xEnd, room.top, doorPaint);
      case 'bottom':
        final xStart = room.left + (room.right - room.left) * room.doorStart / 100;
        final xEnd = room.left + (room.right - room.left) * room.doorEnd / 100;
        drawIsoLine(canvas, size, xStart, room.bottom, xEnd, room.bottom, doorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GeneratedFloorPlanPainter old) =>
    old.darkMode != darkMode || old.locale != locale || old.floorPlan != floorPlan;
}
