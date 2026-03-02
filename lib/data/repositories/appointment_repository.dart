import 'package:hive_ce/hive.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  static const _boxName = 'appointments';

  Future<Box<Appointment>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<Appointment>(_boxName);
    }
    return await Hive.openBox<Appointment>(_boxName);
  }

  Future<List<Appointment>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> add(Appointment appointment) async {
    final box = await _getBox();
    await box.put(appointment.id, appointment);
  }

  Future<void> remove(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _getBox();
    await box.clear();
  }
}
