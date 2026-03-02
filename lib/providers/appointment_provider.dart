import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/appointment.dart';
import '../data/repositories/appointment_repository.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepository();
});

class AppointmentNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    return await ref.watch(appointmentRepositoryProvider).getAll();
  }

  Future<void> add(Appointment appointment) async {
    await ref.read(appointmentRepositoryProvider).add(appointment);
    state = AsyncData(await ref.read(appointmentRepositoryProvider).getAll());
  }

  Future<void> remove(String id) async {
    await ref.read(appointmentRepositoryProvider).remove(id);
    state = AsyncData(await ref.read(appointmentRepositoryProvider).getAll());
  }
}

final appointmentProvider = AsyncNotifierProvider<AppointmentNotifier, List<Appointment>>(
  AppointmentNotifier.new,
);
