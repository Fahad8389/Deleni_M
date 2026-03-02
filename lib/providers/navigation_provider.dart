import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/hospital.dart';
import '../core/constants/app_constants.dart';
import 'hospital_provider.dart';

class RouteInfo {
  final int distanceMeters;
  final int walkMinutes;

  const RouteInfo({required this.distanceMeters, required this.walkMinutes});
}

RouteInfo calculateRouteInfo(Position entrance, Position destination) {
  final dx = (destination.x - entrance.x).abs();
  final dy = (destination.y - entrance.y).abs();
  final distance = sqrt(dx * dx + dy * dy).round();
  final timeInSeconds = distance / AppConstants.walkingSpeedMps;
  final minutes = (timeInSeconds / 60).ceil();
  return RouteInfo(distanceMeters: distance, walkMinutes: minutes < 1 ? 1 : minutes);
}

final routeInfoProvider = Provider<RouteInfo?>((ref) {
  final destination = ref.watch(selectedDestinationProvider);
  if (destination == null) return null;

  final hospital = ref.watch(selectedHospitalProvider);
  final floor = hospital.floorById(destination.floor);
  if (floor == null) return null;

  return calculateRouteInfo(floor.entrance, destination.position);
});
