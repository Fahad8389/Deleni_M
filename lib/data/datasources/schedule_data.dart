import '../models/time_slot.dart';

final List<ClinicSchedule> clinicSchedules = [
  // King Faisal - Cardiology
  ClinicSchedule(
    clinicId: 'cardiology-1f',
    dayOfWeek: 0, // Sunday
    slots: const [
      TimeSlot(time: '09:00', capacity: 5, booked: 2),
      TimeSlot(time: '09:30', capacity: 5, booked: 3),
      TimeSlot(time: '10:00', capacity: 5, booked: 5),
      TimeSlot(time: '10:30', capacity: 5, booked: 1),
      TimeSlot(time: '11:00', capacity: 5, booked: 4),
      TimeSlot(time: '11:30', capacity: 5, booked: 0),
      TimeSlot(time: '13:00', capacity: 5, booked: 2),
      TimeSlot(time: '13:30', capacity: 5, booked: 1),
      TimeSlot(time: '14:00', capacity: 5, booked: 3),
      TimeSlot(time: '15:30', capacity: 5, booked: 5),
    ],
  ),
  ClinicSchedule(
    clinicId: 'cardiology-1f',
    dayOfWeek: 1, // Monday
    slots: const [
      TimeSlot(time: '09:00', capacity: 5, booked: 0),
      TimeSlot(time: '09:30', capacity: 5, booked: 1),
      TimeSlot(time: '10:00', capacity: 5, booked: 0),
      TimeSlot(time: '10:30', capacity: 5, booked: 2),
      TimeSlot(time: '11:00', capacity: 5, booked: 0),
      TimeSlot(time: '13:00', capacity: 5, booked: 1),
      TimeSlot(time: '14:00', capacity: 5, booked: 0),
      TimeSlot(time: '15:00', capacity: 5, booked: 0),
    ],
  ),
  // King Faisal - Neurology
  ClinicSchedule(
    clinicId: 'neurology-1f',
    dayOfWeek: 0, // Sunday
    slots: const [
      TimeSlot(time: '08:00', capacity: 4, booked: 1),
      TimeSlot(time: '08:30', capacity: 4, booked: 2),
      TimeSlot(time: '09:00', capacity: 4, booked: 0),
      TimeSlot(time: '09:30', capacity: 4, booked: 4),
      TimeSlot(time: '10:00', capacity: 4, booked: 1),
      TimeSlot(time: '10:30', capacity: 4, booked: 0),
      TimeSlot(time: '11:00', capacity: 4, booked: 2),
    ],
  ),
  ClinicSchedule(
    clinicId: 'neurology-1f',
    dayOfWeek: 2, // Tuesday
    slots: const [
      TimeSlot(time: '08:00', capacity: 4, booked: 0),
      TimeSlot(time: '08:30', capacity: 4, booked: 0),
      TimeSlot(time: '09:00', capacity: 4, booked: 1),
      TimeSlot(time: '09:30', capacity: 4, booked: 0),
      TimeSlot(time: '10:00', capacity: 4, booked: 0),
      TimeSlot(time: '10:30', capacity: 4, booked: 2),
    ],
  ),
  // King Faisal - Orthopedics
  ClinicSchedule(
    clinicId: 'orthopedics-1f',
    dayOfWeek: 1, // Monday
    slots: const [
      TimeSlot(time: '09:00', capacity: 6, booked: 2),
      TimeSlot(time: '09:30', capacity: 6, booked: 1),
      TimeSlot(time: '10:00', capacity: 6, booked: 3),
      TimeSlot(time: '10:30', capacity: 6, booked: 0),
      TimeSlot(time: '11:00', capacity: 6, booked: 6),
      TimeSlot(time: '11:30', capacity: 6, booked: 2),
      TimeSlot(time: '13:00', capacity: 6, booked: 1),
      TimeSlot(time: '14:00', capacity: 6, booked: 0),
      TimeSlot(time: '15:00', capacity: 6, booked: 3),
    ],
  ),
  ClinicSchedule(
    clinicId: 'orthopedics-1f',
    dayOfWeek: 3, // Wednesday
    slots: const [
      TimeSlot(time: '09:00', capacity: 6, booked: 0),
      TimeSlot(time: '09:30', capacity: 6, booked: 0),
      TimeSlot(time: '10:00', capacity: 6, booked: 1),
      TimeSlot(time: '10:30', capacity: 6, booked: 0),
      TimeSlot(time: '11:00', capacity: 6, booked: 2),
      TimeSlot(time: '13:00', capacity: 6, booked: 0),
      TimeSlot(time: '14:30', capacity: 6, booked: 0),
    ],
  ),
  // King Faisal - Pediatrics
  ClinicSchedule(
    clinicId: 'pediatrics-2f',
    dayOfWeek: 0, // Sunday
    slots: const [
      TimeSlot(time: '08:00', capacity: 8, booked: 3),
      TimeSlot(time: '08:30', capacity: 8, booked: 2),
      TimeSlot(time: '09:00', capacity: 8, booked: 5),
      TimeSlot(time: '09:30', capacity: 8, booked: 1),
      TimeSlot(time: '10:00', capacity: 8, booked: 8),
      TimeSlot(time: '10:30', capacity: 8, booked: 0),
      TimeSlot(time: '13:00', capacity: 8, booked: 4),
      TimeSlot(time: '14:00', capacity: 8, booked: 2),
      TimeSlot(time: '15:00', capacity: 8, booked: 1),
      TimeSlot(time: '16:00', capacity: 8, booked: 0),
    ],
  ),
  ClinicSchedule(
    clinicId: 'pediatrics-2f',
    dayOfWeek: 2, // Tuesday
    slots: const [
      TimeSlot(time: '08:00', capacity: 8, booked: 0),
      TimeSlot(time: '09:00', capacity: 8, booked: 1),
      TimeSlot(time: '10:00', capacity: 8, booked: 0),
      TimeSlot(time: '11:00', capacity: 8, booked: 2),
      TimeSlot(time: '13:00', capacity: 8, booked: 0),
      TimeSlot(time: '14:00', capacity: 8, booked: 0),
      TimeSlot(time: '15:30', capacity: 8, booked: 0),
    ],
  ),
  // King Faisal - Dermatology
  ClinicSchedule(
    clinicId: 'dermatology-2f',
    dayOfWeek: 1, // Monday
    slots: const [
      TimeSlot(time: '09:00', capacity: 4, booked: 1),
      TimeSlot(time: '09:30', capacity: 4, booked: 2),
      TimeSlot(time: '10:00', capacity: 4, booked: 0),
      TimeSlot(time: '10:30', capacity: 4, booked: 3),
      TimeSlot(time: '11:00', capacity: 4, booked: 4),
      TimeSlot(time: '13:00', capacity: 4, booked: 1),
      TimeSlot(time: '14:30', capacity: 4, booked: 0),
    ],
  ),
  ClinicSchedule(
    clinicId: 'dermatology-2f',
    dayOfWeek: 3, // Wednesday
    slots: const [
      TimeSlot(time: '09:00', capacity: 4, booked: 0),
      TimeSlot(time: '09:30', capacity: 4, booked: 0),
      TimeSlot(time: '10:00', capacity: 4, booked: 1),
      TimeSlot(time: '10:30', capacity: 4, booked: 0),
      TimeSlot(time: '11:00', capacity: 4, booked: 0),
      TimeSlot(time: '14:30', capacity: 4, booked: 0),
    ],
  ),
  // Riyadh Care - ENT
  ClinicSchedule(
    clinicId: 'ent-rc-1f',
    dayOfWeek: 0, // Sunday
    slots: const [
      TimeSlot(time: '09:00', capacity: 5, booked: 2),
      TimeSlot(time: '09:30', capacity: 5, booked: 1),
      TimeSlot(time: '10:00', capacity: 5, booked: 3),
      TimeSlot(time: '10:30', capacity: 5, booked: 5),
      TimeSlot(time: '11:00', capacity: 5, booked: 0),
      TimeSlot(time: '13:00', capacity: 5, booked: 2),
      TimeSlot(time: '14:30', capacity: 5, booked: 1),
    ],
  ),
  ClinicSchedule(
    clinicId: 'ent-rc-1f',
    dayOfWeek: 2, // Tuesday
    slots: const [
      TimeSlot(time: '09:00', capacity: 5, booked: 0),
      TimeSlot(time: '09:30', capacity: 5, booked: 0),
      TimeSlot(time: '10:00', capacity: 5, booked: 1),
      TimeSlot(time: '10:30', capacity: 5, booked: 0),
      TimeSlot(time: '11:00', capacity: 5, booked: 0),
      TimeSlot(time: '14:00', capacity: 5, booked: 0),
    ],
  ),
  // Riyadh Care - Ophthalmology
  ClinicSchedule(
    clinicId: 'ophthalmology-rc-1f',
    dayOfWeek: 1, // Monday
    slots: const [
      TimeSlot(time: '08:00', capacity: 4, booked: 1),
      TimeSlot(time: '08:30', capacity: 4, booked: 2),
      TimeSlot(time: '09:00', capacity: 4, booked: 0),
      TimeSlot(time: '09:30', capacity: 4, booked: 4),
      TimeSlot(time: '10:00', capacity: 4, booked: 1),
      TimeSlot(time: '10:30', capacity: 4, booked: 0),
      TimeSlot(time: '11:00', capacity: 4, booked: 2),
    ],
  ),
  ClinicSchedule(
    clinicId: 'ophthalmology-rc-1f',
    dayOfWeek: 3, // Wednesday
    slots: const [
      TimeSlot(time: '08:00', capacity: 4, booked: 0),
      TimeSlot(time: '08:30', capacity: 4, booked: 0),
      TimeSlot(time: '09:00', capacity: 4, booked: 1),
      TimeSlot(time: '09:30', capacity: 4, booked: 0),
      TimeSlot(time: '10:00', capacity: 4, booked: 0),
      TimeSlot(time: '10:30', capacity: 4, booked: 0),
    ],
  ),
];

List<ClinicSchedule> getSchedulesForClinic(String clinicId) {
  return clinicSchedules.where((s) => s.clinicId == clinicId).toList();
}

List<TimeSlot> getAvailableSlots(String clinicId, DateTime date) {
  final dayOfWeek = date.weekday % 7; // Convert to 0=Sunday
  final schedule = clinicSchedules.where(
    (s) => s.clinicId == clinicId && s.dayOfWeek == dayOfWeek,
  );
  if (schedule.isEmpty) return [];
  return schedule.first.slots;
}
