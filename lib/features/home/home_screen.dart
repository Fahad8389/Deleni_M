import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../shared/widgets/accessibility_banner.dart';
import 'widgets/feature_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final hospital = ref.watch(selectedHospitalProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final isDark = settings.darkMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AccessibilityBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _QuickToggle(
                              icon: Icons.language,
                              label: settings.language == 'en' ? 'AR' : 'EN',
                              onTap: () {
                                ref.read(settingsProvider.notifier).setLanguage(
                                  settings.language == 'en' ? 'ar' : 'en',
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _QuickToggle(
                              icon: Icons.accessible,
                              label: '',
                              isActive: settings.accessibilityMode,
                              activeColor: AppColors.yellow,
                              onTap: () {
                                ref.read(settingsProvider.notifier)
                                    .setAccessibilityMode(!settings.accessibilityMode);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => context.go('/settings'),
                          icon: Icon(
                            Icons.settings_outlined,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // App title
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: isAccessible ? 34 : 26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isAccessible ? 16 : 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hospital name chip — Notion tag style
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkHighlight : AppColors.blueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        hospital.name.get(settings.language),
                        style: TextStyle(
                          color: isDark ? AppColors.darkBlue : AppColors.blue,
                          fontSize: isAccessible ? 13 : 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Feature cards grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: [
                        FeatureCard(
                          icon: Icons.search_rounded,
                          title: l10n.searchClinics,
                          subtitle: l10n.searchClinicsDesc,
                          color: AppColors.blue,
                          chipBg: AppColors.blueBg,
                          onTap: () => context.go('/map'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.people_outlined,
                          title: l10n.visitPatient,
                          subtitle: l10n.visitPatientDesc,
                          color: AppColors.purple,
                          chipBg: AppColors.purpleBg,
                          onTap: () => context.go('/visitor'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.calendar_month_outlined,
                          title: l10n.myAppointments,
                          subtitle: l10n.myAppointmentsDesc,
                          color: AppColors.green,
                          chipBg: AppColors.greenBg,
                          onTap: () => context.go('/appointments'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.emergency_outlined,
                          title: l10n.emergency,
                          subtitle: l10n.emergencyDesc,
                          color: AppColors.red,
                          chipBg: AppColors.redBg,
                          onTap: () => context.go('/emergency'),
                          isAccessible: isAccessible,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _QuickToggle({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isActive
        ? (activeColor ?? AppColors.blue).withValues(alpha: 0.15)
        : (isDark ? AppColors.darkHighlight : AppColors.highlight);
    final activeText = isActive
        ? (activeColor ?? AppColors.blue)
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: activeBg,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: activeText),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: activeText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
