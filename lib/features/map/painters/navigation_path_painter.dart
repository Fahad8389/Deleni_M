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

  NavigationPathPainter({
    required this.entrance,
    required this.destination,
    required this.progress,
    required this.pulseValue,
    this.isEmergency = false,
    this.isAccessibility = false,
    this.darkMode = false,
  });

  Offset _toCanvas(Position p, Size size) => toIso(p.x, p.y, size);

  /// Notion ink color — dark text in light mode, light in dark mode.
  /// Emergency stays red, accessibility stays yellow.
  Color get _pathColor {
    if (isEmergency) return AppColors.red;
    if (isAccessibility) return AppColors.yellow;
    return darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);
  }

  double get _lineWidth => 3.0;

  List<Position> _buildWaypoints() {
    final pts = <Position>[];
    pts.add(entrance);

    const corridorY = 50.0;

    final eX = entrance.x;
    final eY = entrance.y;
    final dX = destination.x;
    final dY = destination.y;

    if ((eY - dY).abs() < 8 && (eX - dX).abs() < 8) {
      pts.add(destination);
      return pts;
    }

    if ((eY - corridorY).abs() > 5) {
      pts.add(Position(x: eX, y: corridorY));
    }

    if ((eX - dX).abs() > 5) {
      pts.add(Position(x: dX, y: corridorY));
    }

    if ((corridorY - dY).abs() > 5) {
      pts.add(Position(x: dX, y: dY));
    }

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

    // Dashed leading edge — draw the last ~15% as dashes during animation
    if (progress < 1.0) {
      _paintDashedLeadingEdge(canvas, metrics, totalLength, revealLength);
      // Draw the solid part (up to the dash start)
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
      // Fully revealed — solid line, no glow
      final pathPaint = Paint()
        ..color = _pathColor
        ..strokeWidth = _lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(revealedPath, pathPaint);
    }

    // Waypoint dots at turns
    _paintWaypointDots(canvas, size);

    // Entrance marker — hollow circle with gentle pulse
    _paintEntranceMarker(canvas, size);

    // Destination marker — filled circle with white border
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
        // Extract this dash segment from the metrics
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

    // Draw small dots at intermediate waypoints (not entrance/destination)
    for (int i = 1; i < waypoints.length - 1; i++) {
      final pt = _toCanvas(waypoints[i], size);
      canvas.drawCircle(pt, 3.0, dotPaint);
    }
  }

  void _paintEntranceMarker(Canvas canvas, Size size) {
    final center = _toCanvas(entrance, size);
    final pulse = 0.8 + 0.4 * sin(pulseValue * 2 * pi);
    final inkColor = darkMode ? const Color(0xFFE3E2E0) : const Color(0xFF37352F);

    // Gentle pulsing ring
    canvas.drawCircle(
      center,
      8.0 * pulse,
      Paint()
        ..color = inkColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Hollow circle
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

    // Filled circle
    canvas.drawCircle(center, 7, Paint()..color = color);

    // White border
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = darkMode ? const Color(0xFF191919) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Outer ring for visibility
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
        oldDelegate.darkMode != darkMode;
  }
}
