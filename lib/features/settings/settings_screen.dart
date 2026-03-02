import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../shared/widgets/back_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final hospitals = ref.watch(hospitalsProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Spacer(),
                  Icon(Icons.settings_rounded, color: AppColors.deepTeal, size: isAccessible ? 28 : 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.settings,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: isAccessible ? 22 : 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 80), // Balance
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  // Hospital selector
                  _SectionTitle(title: l10n.selectHospital, isAccessible: isAccessible),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: hospitals.map((h) {
                          final isSelected = h.id == settings.defaultHospitalId;
                          return RadioListTile<String>(
                            value: h.id,
                            groupValue: settings.defaultHospitalId,
                            onChanged: (v) {
                              if (v != null) {
                                ref.read(settingsProvider.notifier).setDefaultHospitalId(v);
                              }
                            },
                            title: Text(
                              h.name.get(settings.language),
                              style: TextStyle(
                                fontSize: isAccessible ? 16 : 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              h.address.get(settings.language),
                              style: TextStyle(fontSize: isAccessible ? 13 : 11),
                            ),
                            activeColor: AppColors.deepTeal,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Appearance
                  _SectionTitle(title: l10n.appearance, isAccessible: isAccessible),
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    isAccessible: isAccessible,
                    trailing: Switch(
                      value: settings.darkMode,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language
                  _SectionTitle(title: l10n.languageRegion, isAccessible: isAccessible),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.language_rounded, color: AppColors.deepTeal, size: isAccessible ? 24 : 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                _LangButton(
                                  label: l10n.english,
                                  isSelected: settings.language == 'en',
                                  onTap: () => ref.read(settingsProvider.notifier).setLanguage('en'),
                                  isAccessible: isAccessible,
                                ),
                                const SizedBox(width: 8),
                                _LangButton(
                                  label: l10n.arabic,
                                  isSelected: settings.language == 'ar',
                                  onTap: () => ref.read(settingsProvider.notifier).setLanguage('ar'),
                                  isAccessible: isAccessible,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accessibility
                  _SectionTitle(title: l10n.accessibility, isAccessible: isAccessible),
                  _SettingsTile(
                    icon: Icons.accessible_rounded,
                    iconColor: AppColors.gold,
                    title: l10n.accessibilityMode,
                    subtitle: l10n.accessibilityModeDesc,
                    isAccessible: isAccessible,
                    trailing: Switch(
                      value: settings.accessibilityMode,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setAccessibilityMode(v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notifications
                  _SectionTitle(title: l10n.notifications, isAccessible: isAccessible),
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.notifications,
                    subtitle: l10n.notificationsDesc,
                    isAccessible: isAccessible,
                    trailing: Switch(
                      value: settings.notifications,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About
                  _SectionTitle(title: l10n.about, isAccessible: isAccessible),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aboutDesc,
                            style: TextStyle(
                              fontSize: isAccessible ? 15 : 13,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${l10n.version} ${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: isAccessible ? 13 : 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.madeWith,
                            style: TextStyle(
                              fontSize: isAccessible ? 13 : 11,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isAccessible;

  const _SectionTitle({required this.title, this.isAccessible = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isAccessible ? 15 : 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isAccessible;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.isAccessible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? AppColors.deepTeal, size: isAccessible ? 24 : 20),
        title: Text(title, style: TextStyle(fontSize: isAccessible ? 16 : 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: isAccessible ? 13 : 11)),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAccessible;

  const _LangButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isAccessible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected ? AppColors.deepTeal : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isAccessible ? 12 : 10),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: isAccessible ? 15 : 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
