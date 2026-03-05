import '../datasources/hospital_data.dart';
import '../models/hospital.dart';

class HospitalRepository {
  List<Hospital> _generatedHospitals = [];

  void setGeneratedHospitals(List<Hospital> generated) {
    _generatedHospitals = generated;
  }

  List<Hospital> getAll() => [...hospitals, ..._generatedHospitals];

  Hospital? getById(String id) {
    for (final h in hospitals) {
      if (h.id == id) return h;
    }
    for (final h in _generatedHospitals) {
      if (h.id == id) return h;
    }
    return null;
  }

  Hospital getDefault() => hospitals.first;

  Destination? findDestinationById(String id) {
    for (final h in getAll()) {
      for (final d in h.allDestinations) {
        if (d.id == id) return d;
      }
    }
    return null;
  }

  /// Find a destination by room number across all hospitals.
  /// Returns (hospital, destination) or null.
  (Hospital, Destination)? findByRoomNumber(String roomNumber) {
    final q = roomNumber.toLowerCase().trim();
    for (final h in getAll()) {
      for (final d in h.allDestinations) {
        if (d.roomNumber?.toLowerCase() == q) {
          return (h, d);
        }
      }
    }
    return null;
  }
}
