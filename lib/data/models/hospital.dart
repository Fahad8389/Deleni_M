import 'package:flutter/foundation.dart';

@immutable
class LocaleString {
  final String en;
  final String ar;

  const LocaleString({required this.en, required this.ar});

  String get(String locale) => locale == 'ar' ? ar : en;
}

@immutable
class Position {
  final double x;
  final double y;

  const Position({required this.x, required this.y});
}

enum DestinationType { clinic, department, room, emergency }

@immutable
class Destination {
  final String id;
  final LocaleString name;
  final DestinationType type;
  final int floor;
  final Position position;
  final String? roomNumber;

  const Destination({
    required this.id,
    required this.name,
    required this.type,
    required this.floor,
    required this.position,
    this.roomNumber,
  });
}

@immutable
class Floor {
  final int id;
  final LocaleString name;
  final Position entrance;
  final Position stairsPosition;
  final List<Destination> destinations;

  const Floor({
    required this.id,
    required this.name,
    required this.entrance,
    required this.stairsPosition,
    required this.destinations,
  });
}

@immutable
class Hospital {
  final String id;
  final LocaleString name;
  final LocaleString address;
  final List<Floor> floors;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.floors,
  });

  List<Destination> get allDestinations =>
      floors.expand((f) => f.destinations).toList();

  Destination? get emergencyDestination {
    for (final floor in floors) {
      for (final dest in floor.destinations) {
        if (dest.type == DestinationType.emergency) return dest;
      }
    }
    return null;
  }

  List<Destination> searchDestinations(String query, String locale) {
    final q = query.toLowerCase();
    return allDestinations.where((d) {
      final name = d.name.get(locale).toLowerCase();
      final room = d.roomNumber?.toLowerCase() ?? '';
      return name.contains(q) || room.contains(q);
    }).toList();
  }

  Floor? floorById(int id) {
    for (final f in floors) {
      if (f.id == id) return f;
    }
    return null;
  }
}
