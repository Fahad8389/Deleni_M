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
                        // Quick toggles
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
                              activeColor: AppColors.gold,
                              onTap: () {
                                ref.read(settingsProvider.notifier)
                                    .setAccessibilityMode(!settings.accessibilityMode);
                              },
                            ),
                          ],
                        ),
                        // Settings button
                        IconButton(
                          onPressed: () => context.go('/settings'),
                          icon: const Icon(Icons.settings_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // App title
                    Icon(
                      Icons.local_hospital_rounded,
                      size: isAccessible ? 56 : 48,
                      color: AppColors.deepTeal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: isAccessible ? 34 : 28,
                        color: AppColors.deepTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isAccessible ? 16 : 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hospital name chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.deepTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hospital.name.get(settings.language),
                        style: TextStyle(
                          color: AppColors.deepTeal,
                          fontSize: isAccessible ? 14 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Feature cards grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        FeatureCard(
                          icon: Icons.search_rounded,
                          title: l10n.searchClinics,
                          subtitle: l10n.searchClinicsDesc,
                          color: AppColors.deepTeal,
                          onTap: () => context.go('/map'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.people_rounded,
                          title: l10n.visitPatient,
                          subtitle: l10n.visitPatientDesc,
                          color: const Color(0xFF7C3AED),
                          onTap: () => context.go('/visitor'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.calendar_month_rounded,
                          title: l10n.myAppointments,
                          subtitle: l10n.myAppointmentsDesc,
                          color: AppColors.datePalmGreen,
                          onTap: () => context.go('/appointments'),
                          isAccessible: isAccessible,
                        ),
                        FeatureCard(
                          icon: Icons.emergency_rounded,
                          title: l10n.emergency,
                          subtitle: l10n.emergencyDesc,
                          color: AppColors.terracotta,
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
    final color = isActive ? (activeColor ?? AppColors.deepTeal) : null;

    return Material(
      color: color?.withOpacity(0.1) ?? Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color ?? Theme.of(context).colorScheme.onSurface),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color ?? Theme.of(context).colorScheme.onSurface,
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
