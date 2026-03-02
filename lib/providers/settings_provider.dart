import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/settings_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final repo = ref.watch(settingsRepositoryProvider);
    return SettingsState(
      language: repo.language,
      darkMode: repo.darkMode,
      accessibilityMode: repo.accessibilityMode,
      notifications: repo.notifications,
      defaultHospitalId: repo.defaultHospitalId,
    );
  }

  Future<void> setLanguage(String lang) async {
    await ref.read(settingsRepositoryProvider).setLanguage(lang);
    state = state.copyWith(language: lang);
  }

  Future<void> setDarkMode(bool value) async {
    await ref.read(settingsRepositoryProvider).setDarkMode(value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setAccessibilityMode(bool value) async {
    await ref.read(settingsRepositoryProvider).setAccessibilityMode(value);
    state = state.copyWith(accessibilityMode: value);
  }

  Future<void> setNotifications(bool value) async {
    await ref.read(settingsRepositoryProvider).setNotifications(value);
    state = state.copyWith(notifications: value);
  }

  Future<void> setDefaultHospitalId(String id) async {
    await ref.read(settingsRepositoryProvider).setDefaultHospitalId(id);
    state = state.copyWith(defaultHospitalId: id);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsState {
  final String language;
  final bool darkMode;
  final bool accessibilityMode;
  final bool notifications;
  final String defaultHospitalId;

  const SettingsState({
    this.language = 'en',
    this.darkMode = false,
    this.accessibilityMode = false,
    this.notifications = true,
    this.defaultHospitalId = 'king-faisal',
  });

  SettingsState copyWith({
    String? language,
    bool? darkMode,
    bool? accessibilityMode,
    bool? notifications,
    String? defaultHospitalId,
  }) {
    return SettingsState(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      notifications: notifications ?? this.notifications,
      defaultHospitalId: defaultHospitalId ?? this.defaultHospitalId,
    );
  }
}
