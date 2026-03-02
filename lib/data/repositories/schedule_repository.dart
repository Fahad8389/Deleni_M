import '../datasources/schedule_data.dart' as data;
import '../models/time_slot.dart';

class ScheduleRepository {
  List<ClinicSchedule> getSchedulesForClinic(String clinicId) {
    return data.getSchedulesForClinic(clinicId);
  }

  List<TimeSlot> getSlotsForDate(String clinicId, DateTime date) {
    return data.getAvailableSlots(clinicId, date);
  }

  /// Returns the days of week (0=Sun..6=Sat) this clinic has schedules.
  List<int> getAvailableDays(String clinicId) {
    return data.clinicSchedules
        .where((s) => s.clinicId == clinicId)
        .map((s) => s.dayOfWeek)
        .toList();
  }
}
