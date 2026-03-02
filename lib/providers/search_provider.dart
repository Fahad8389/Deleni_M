import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/hospital.dart';
import 'hospital_provider.dart';
import 'settings_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final hospital = ref.watch(selectedHospitalProvider);
  final locale = ref.watch(settingsProvider).language;

  if (query.isEmpty) return hospital.allDestinations;
  return hospital.searchDestinations(query, locale);
});
