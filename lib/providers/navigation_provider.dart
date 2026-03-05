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

RouteInfo calculateRouteInfo(Position entrance, Position destination, {int floorDifference = 0}) {
  final dx = (destination.x - entrance.x).abs();
  final dy = (destination.y - entrance.y).abs();
  final distance = sqrt(dx * dx + dy * dy).round();
  // Add ~30m per floor of difference
  final totalDistance = distance + (floorDifference.abs() * 30);
  final timeInSeconds = totalDistance / AppConstants.walkingSpeedMps;
  final minutes = (timeInSeconds / 60).ceil();
  return RouteInfo(distanceMeters: totalDistance, walkMinutes: minutes < 1 ? 1 : minutes);
}

final routeInfoProvider = Provider<RouteInfo?>((ref) {
  final destination = ref.watch(selectedDestinationProvider);
  if (destination == null) return null;

  final hospital = ref.watch(selectedHospitalProvider);
  final currentFloorId = ref.watch(selectedFloorProvider);
  final floor = hospital.floorById(destination.floor);
  if (floor == null) return null;

  final floorDiff = (destination.floor - currentFloorId).abs();
  return calculateRouteInfo(floor.entrance, destination.position, floorDifference: floorDiff);
});
