import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';

class SettingsPanel extends ConsumerWidget {
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final allHospitals = ref.watch(hospitalsProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final isDark = settings.darkMode;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      children: [
        // Hospital selector
        _SectionTitle(title: l10n.selectHospital, isAccessible: isAccessible),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: allHospitals.map((h) {
                final isSelected = h.id == settings.defaultHospitalId;
                return RadioListTile<String>(
                  value: h.id,
                  groupValue: settings.defaultHospitalId,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(settingsProvider.notifier).setDefaultHospitalId(v);
                    }
                  },
                  title: Text(h.name.get(settings.language),
                    style: TextStyle(
                      fontSize: isAccessible ? 14 : 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                  subtitle: Text(h.address.get(settings.language),
                    style: Theme.of(context).textTheme.bodySmall),
                  activeColor: isDark ? AppColors.darkBlue : AppColors.blue,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Dark mode
        _SectionTitle(title: l10n.appearance, isAccessible: isAccessible),
        _SettingsTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.darkMode,
          subtitle: l10n.darkModeDesc,
          isAccessible: isAccessible,
          trailing: Switch(
            value: settings.darkMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v),
          ),
        ),
        const SizedBox(height: 14),

        // Language
        _SectionTitle(title: l10n.languageRegion, isAccessible: isAccessible),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.language_outlined,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  size: isAccessible ? 20 : 18),
                const SizedBox(width: 10),
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
        const SizedBox(height: 14),

        // Accessibility
        _SectionTitle(title: l10n.accessibility, isAccessible: isAccessible),
        _SettingsTile(
          icon: Icons.accessible_outlined,
          iconColor: AppColors.yellow,
          title: l10n.accessibilityMode,
          subtitle: l10n.accessibilityModeDesc,
          isAccessible: isAccessible,
          trailing: Switch(
            value: settings.accessibilityMode,
            onChanged: (v) => ref.read(settingsProvider.notifier).setAccessibilityMode(v),
          ),
        ),
        const SizedBox(height: 14),

        // Notifications
        _SectionTitle(title: l10n.notifications, isAccessible: isAccessible),
        _SettingsTile(
          icon: Icons.notifications_outlined,
          title: l10n.notifications,
          subtitle: l10n.notificationsDesc,
          isAccessible: isAccessible,
          trailing: Switch(
            value: settings.notifications,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
          ),
        ),
        const SizedBox(height: 14),

        // About
        _SectionTitle(title: l10n.about, isAccessible: isAccessible),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.aboutDesc,
                  style: TextStyle(fontSize: isAccessible ? 13 : 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                const SizedBox(height: 10),
                Text('${l10n.version} ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(l10n.madeWith,
                  style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
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
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: isAccessible ? 11 : 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: ListTile(
        leading: Icon(icon,
          color: iconColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          size: isAccessible ? 20 : 18),
        title: Text(title,
          style: TextStyle(fontSize: isAccessible ? 14 : 13, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.darkBlue : AppColors.blue;

    return Expanded(
      child: Material(
        color: isSelected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: isAccessible ? 9 : 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? null
                  : Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Text(label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: isAccessible ? 13 : 12)),
          ),
        ),
      ),
    );
  }
}
