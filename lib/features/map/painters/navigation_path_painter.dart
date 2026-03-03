import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/hospital.dart';

class NavigationPathPainter extends CustomPainter {
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

  Offset _toCanvas(Position p, Size size) =>
      Offset(p.x / 100 * size.width, p.y / 100 * size.height);

  Color get _pathColor {
    if (isEmergency) return AppColors.red;
    if (isAccessibility) return AppColors.yellow;
    return darkMode ? AppColors.darkBlue : AppColors.blue;
  }

  double get _lineWidth {
    if (isEmergency) return 6.0;
    if (isAccessibility) return 5.5;
    return 5.0;
  }

  List<Position> _buildWaypoints() {
    final pts = <Position>[];
    pts.add(entrance);

    const corridorY = 48.0;

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

    // Subtle shadow
    final shadowPaint = Paint()
      ..color = _pathColor.withValues(alpha: 0.15)
      ..strokeWidth = _lineWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(revealedPath, shadowPaint);

    // Main path — clean solid line
    final pathPaint = Paint()
      ..color = _pathColor
      ..strokeWidth = _lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(revealedPath, pathPaint);

    // Direction arrows
    _paintArrows(canvas, metrics, totalLength);

    // Entrance marker
    _paintEntranceMarker(canvas, size);

    // Destination marker
    if (progress >= 1.0) {
      _paintDestinationMarker(canvas, size);
    }
  }

  void _paintArrows(Canvas canvas, List<ui.PathMetric> metrics, double totalLength) {
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (double t = 0.3; t < progress; t += 0.3) {
      final dist = t * totalLength;
      _drawArrowAt(canvas, metrics, dist, arrowPaint);
    }
  }

  void _drawArrowAt(Canvas canvas, List<ui.PathMetric> metrics, double dist, Paint paint) {
    double accumulated = 0;
    for (final metric in metrics) {
      if (accumulated + metric.length >= dist) {
        final localDist = dist - accumulated;
        final tangent = metric.getTangentForOffset(localDist);
        if (tangent == null) return;

        final pos = tangent.position;
        final angle = tangent.angle;
        const arrowSize = 5.0;

        final p1 = Offset(
          pos.dx - arrowSize * cos(angle - 0.5),
          pos.dy - arrowSize * sin(angle - 0.5),
        );
        final p2 = Offset(
          pos.dx - arrowSize * cos(angle + 0.5),
          pos.dy - arrowSize * sin(angle + 0.5),
        );

        canvas.drawLine(p1, pos, paint);
        canvas.drawLine(p2, pos, paint);
        return;
      }
      accumulated += metric.length;
    }
  }

  void _paintEntranceMarker(Canvas canvas, Size size) {
    final center = _toCanvas(entrance, size);
    final pulse = 0.8 + 0.5 * sin(pulseValue * 2 * pi);
    final radius = 8.0 * pulse;
    final markerColor = darkMode ? AppColors.darkBlue : AppColors.blue;

    // Pulsing ring
    canvas.drawCircle(
      center,
      radius + 3,
      Paint()
        ..color = markerColor.withValues(alpha: 0.2 * (1.2 - pulse / 1.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Solid center
    canvas.drawCircle(center, 7, Paint()..color = markerColor);
    // White inner dot
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  void _paintDestinationMarker(Canvas canvas, Size size) {
    final center = _toCanvas(destination, size);
    final color = _pathColor;

    // Pin body
    canvas.drawCircle(center, 9, Paint()..color = color);

    // White border
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner dot
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);

    // Pin pointer
    final pinPath = Path()
      ..moveTo(center.dx - 4, center.dy + 7)
      ..lineTo(center.dx, center.dy + 14)
      ..lineTo(center.dx + 4, center.dy + 7)
      ..close();
    canvas.drawPath(pinPath, Paint()..color = color);
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
