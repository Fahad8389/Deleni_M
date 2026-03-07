import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/hospital.dart';
import '../../../shared/painters/isometric_helper.dart';

class NavigationPathPainter extends CustomPainter with IsometricHelper {
  final Position entrance;
  final Position destination;
  final double progress;
  final double pulseValue;
  final bool isEmergency;
  final bool isAccessibility;
  final bool darkMode;

  /// When true, coordinates map directly to image pixels (X=left/right%, Y=top/bottom%)
  /// instead of isometric projection.
  final bool flatMode;

  /// Corridor bounds for path routing (percentage 0-100).
  final double? corridorLeft;
  final double? corridorTop;
  final double? corridorRight;
  final double? corridorBottom;

  NavigationPathPainter({
    required this.entrance,
    required this.destination,
    required this.progress,
    required this.pulseValue,
    this.isEmergency = false,
    this.isAccessibility = false,
    this.darkMode = false,
    this.flatMode = false,
    this.corridorLeft,
    this.corridorTop,
    this.corridorRight,
    this.corridorBottom,
  });

  Offset _toCanvas(Position p, Size size) {
    if (flatMode) {
      return Offset(
        (p.x / 100.0) * size.width,
        (p.y / 100.0) * size.height,
      );
    }
    return toIso(p.x, p.y, size);
  }

  Color get _pathColor {
    if (isEmergency) return AppColors.red;
    if (isAccessibility) return AppColors.yellow;
    return darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
  }

  double get _lineWidth => 3.0;

  List<Position> _buildWaypoints() {
    final pts = <Position>[];
    pts.add(entrance);

    final eX = entrance.x;
    final eY = entrance.y;
    final dX = destination.x;
    final dY = destination.y;

    // If very close, just go direct
    if ((eY - dY).abs() < 8 && (eX - dX).abs() < 8) {
      pts.add(destination);
      return pts;
    }

    if (flatMode) {
      // Flat mode: X=horizontal (left/right), Y=vertical (top/bottom)
      final cLeft = corridorLeft ?? 20.0;
      final cRight = corridorRight ?? 80.0;
      final cTop = corridorTop ?? 40.0;
      final cBottom = corridorBottom ?? 60.0;
      final corridorCenterY = (cTop + cBottom) / 2;

      // Step 1: Move vertically to corridor center
      if ((eY - corridorCenterY).abs() > 5) {
        pts.add(Position(x: eX, y: corridorCenterY));
      }

      // Step 2: Move horizontally into corridor X range
      final enterX = eX.clamp(cLeft, cRight);
      if ((eX - enterX).abs() > 3) {
        pts.add(Position(x: enterX, y: corridorCenterY));
      }

      // Step 3: Walk along corridor to destination's X
      final exitX = dX.clamp(cLeft, cRight);
      if ((enterX - exitX).abs() > 5) {
        pts.add(Position(x: exitX, y: corridorCenterY));
      }

      // Step 4: Move vertically from corridor to destination Y
      if ((corridorCenterY - dY).abs() > 5) {
        pts.add(Position(x: exitX, y: dY));
      }

      // Step 5: Move horizontally to final destination X
      if ((exitX - dX).abs() > 3) {
        pts.add(Position(x: dX, y: dY));
      }
    } else {
      // Isometric mode: X=depth, Y=lateral
      const corridorY = 50.0;
      final corridorMinX = corridorLeft ?? 24.0;
      final corridorMaxX = corridorRight ?? 82.0;

      final enterCorridorX = eX.clamp(corridorMinX, corridorMaxX);
      if ((eX - enterCorridorX).abs() > 3) {
        pts.add(Position(x: enterCorridorX, y: eY));
      }

      if ((eY - corridorY).abs() > 5) {
        pts.add(Position(x: enterCorridorX, y: corridorY));
      }

      final exitCorridorX = dX.clamp(corridorMinX, corridorMaxX);
      if ((enterCorridorX - exitCorridorX).abs() > 5) {
        pts.add(Position(x: exitCorridorX, y: corridorY));
      }

      if ((corridorY - dY).abs() > 5) {
        pts.add(Position(x: exitCorridorX, y: dY));
      }

      if ((exitCorridorX - dX).abs() > 3) {
        pts.add(Position(x: dX, y: dY));
      }
    }

    // Make sure we end at destination
    if (pts.last.x != dX || pts.last.y != dY) {
      pts.add(destination);
    }

    return pts;
  }

  Path _buildPath(Size size) {
    final waypoints = _buildWaypoints();
    final path = Path();
    if (waypoints.isEmpty) return path;

    final first = _toCanvas(waypoints.first, size);
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < waypoints.length; i++) {
      final pt = _toCanvas(waypoints[i], size);
      path.lineTo(pt.dx, pt.dy);
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final fullPath = _buildPath(size);
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold<double>(0, (sum, m) => sum + m.length);
    final revealLength = totalLength * progress.clamp(0.0, 1.0);

    final revealedPath = Path();
    double remaining = revealLength;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final extract = min(remaining, metric.length);
      revealedPath.addPath(metric.extractPath(0, extract), Offset.zero);
      remaining -= extract;
    }

    if (progress < 1.0) {
      _paintDashedLeadingEdge(canvas, metrics, totalLength, revealLength);
      final solidLength = (revealLength - totalLength * 0.12).clamp(0.0, revealLength);
      if (solidLength > 0) {
        final solidPath = Path();
        double rem = solidLength;
        for (final metric in metrics) {
          if (rem <= 0) break;
          final ext = min(rem, metric.length);
          solidPath.addPath(metric.extractPath(0, ext), Offset.zero);
          rem -= ext;
        }
        final pathPaint = Paint()
          ..color = _pathColor
          ..strokeWidth = _lineWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(solidPath, pathPaint);
      }
    } else {
      final pathPaint = Paint()
        ..color = _pathColor
        ..strokeWidth = _lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(revealedPath, pathPaint);
    }

    _paintWaypointDots(canvas, size);
    _paintEntranceMarker(canvas, size);

    if (progress >= 1.0) {
      _paintDestinationMarker(canvas, size);
    }
  }

  void _paintDashedLeadingEdge(
    Canvas canvas,
    List<ui.PathMetric> metrics,
    double totalLength,
    double revealLength,
  ) {
    final dashStart = (revealLength - totalLength * 0.12).clamp(0.0, revealLength);
    const dashLength = 6.0;
    const gapLength = 4.0;

    final dashPaint = Paint()
      ..color = _pathColor.withValues(alpha: 0.6)
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double pos = dashStart;
    bool drawing = true;
    while (pos < revealLength) {
      final segEnd = min(pos + (drawing ? dashLength : gapLength), revealLength);
      if (drawing) {
        final dashPath = _extractSubPath(metrics, pos, segEnd);
        if (dashPath != null) {
          canvas.drawPath(dashPath, dashPaint);
        }
      }
      pos = segEnd;
      drawing = !drawing;
    }
  }

  Path? _extractSubPath(List<ui.PathMetric> metrics, double start, double end) {
    final path = Path();
    double accumulated = 0;
    for (final metric in metrics) {
      final metricEnd = accumulated + metric.length;
      if (metricEnd <= start) {
        accumulated = metricEnd;
        continue;
      }
      if (accumulated >= end) break;

      final localStart = (start - accumulated).clamp(0.0, metric.length);
      final localEnd = (end - accumulated).clamp(0.0, metric.length);
      if (localEnd > localStart) {
        path.addPath(metric.extractPath(localStart, localEnd), Offset.zero);
      }
      accumulated = metricEnd;
    }
    return path;
  }

  void _paintWaypointDots(Canvas canvas, Size size) {
    final waypoints = _buildWaypoints();
    if (waypoints.length <= 2) return;

    final dotPaint = Paint()..color = _pathColor;

    for (int i = 1; i < waypoints.length - 1; i++) {
      final pt = _toCanvas(waypoints[i], size);
      canvas.drawCircle(pt, 3.0, dotPaint);
    }
  }

  void _paintEntranceMarker(Canvas canvas, Size size) {
    final center = _toCanvas(entrance, size);
    final pulse = 0.8 + 0.4 * sin(pulseValue * 2 * pi);
    final inkColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);

    canvas.drawCircle(
      center,
      8.0 * pulse,
      Paint()
        ..color = inkColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color = inkColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintDestinationMarker(Canvas canvas, Size size) {
    final center = _toCanvas(destination, size);
    final color = _pathColor;

    canvas.drawCircle(center, 7, Paint()..color = color);

    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = darkMode ? const Color(0xFF191919) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.drawCircle(
      center,
      9.5,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant NavigationPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.entrance.x != entrance.x ||
        oldDelegate.entrance.y != entrance.y ||
        oldDelegate.destination.x != destination.x ||
        oldDelegate.destination.y != destination.y ||
        oldDelegate.isEmergency != isEmergency ||
        oldDelegate.isAccessibility != isAccessibility ||
        oldDelegate.darkMode != darkMode ||
        oldDelegate.flatMode != flatMode;
  }
}
