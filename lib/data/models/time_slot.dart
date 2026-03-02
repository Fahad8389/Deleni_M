import 'package:flutter/foundation.dart';

enum SlotStatus { available, limited, full }

@immutable
class TimeSlot {
  final String time; // "HH:mm"
  final int capacity;
  final int booked;

  const TimeSlot({
    required this.time,
    required this.capacity,
    required this.booked,
  });

  int get remaining => capacity - booked;

  SlotStatus get status {
    if (remaining <= 0) return SlotStatus.full;
    if (remaining / capacity <= 0.33) return SlotStatus.limited;
    return SlotStatus.available;
  }
}

@immutable
class ClinicSchedule {
  final String clinicId;
  final int dayOfWeek; // 0 = Sunday
  final List<TimeSlot> slots;

  const ClinicSchedule({
    required this.clinicId,
    required this.dayOfWeek,
    required this.slots,
  });
}
