import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/hospital.dart';
import '../data/repositories/hospital_repository.dart';
import 'settings_provider.dart';

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepository();
});

final hospitalsProvider = Provider<List<Hospital>>((ref) {
  return ref.watch(hospitalRepositoryProvider).getAll();
});

final selectedHospitalProvider = Provider<Hospital>((ref) {
  final hospitalId = ref.watch(settingsProvider).defaultHospitalId;
  final repo = ref.watch(hospitalRepositoryProvider);
  return repo.getById(hospitalId) ?? repo.getDefault();
});

final selectedFloorProvider = StateProvider<int>((ref) => 0);

final selectedDestinationProvider = StateProvider<Destination?>((ref) => null);
