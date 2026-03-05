import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../shared/widgets/accessibility_banner.dart';
import 'widgets/feature_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  void _showHospitalPicker(BuildContext context, WidgetRef ref, SettingsState settings, bool isDark) {
    final hospitals = ref.read(hospitalsProvider);
    final currentId = settings.defaultHospitalId;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...hospitals.map((h) {
                final isSelected = h.id == currentId;
                return ListTile(
                  leading: Icon(
                    Icons.local_hospital_outlined,
                    color: isSelected
                        ? (isDark ? AppColors.darkBlue : AppColors.blue)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  title: Text(
                    h.name.get(settings.language),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: isDark ? AppColors.darkBlue : AppColors.blue)
                      : null,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setDefaultHospitalId(h.id);
                    Navigator.pop(ctx);
                  },
                );
              }),
              const Divider(),
              ListTile(
                leading: Icon(Icons.add_circle_outline,
                    color: isDark ? AppColors.darkBlue : AppColors.blue),
                title: Text(
                  AppLocalizations(settings.language).addHospitalWithAI,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations(settings.language).uploadFloorPlans,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/add-hospital');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 12),
            // Top bar — toggles + settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: isAccessible ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showHospitalPicker(context, ref, settings, isDark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkHighlight : AppColors.highlight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                hospital.name.get(settings.language),
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _QuickToggle(
                    icon: Icons.translate,
                    label: settings.language == 'en' ? 'AR' : 'EN',
                    onTap: () {
                      ref.read(settingsProvider.notifier).setLanguage(
                        settings.language == 'en' ? 'ar' : 'en',
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _QuickToggle(
                    icon: Icons.accessibility_new,
                    label: '',
                    isActive: settings.accessibilityMode,
                    activeColor: AppColors.yellow,
                    onTap: () {
                      ref.read(settingsProvider.notifier)
                          .setAccessibilityMode(!settings.accessibilityMode);
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => context.go('/settings'),
                    icon: Icon(
                      Icons.tune,
                      size: 20,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tagline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontSize: isAccessible ? 15 : 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Feature cards — each in its own card with subtle pulse
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, _) {
                    // 50% intensity: scale between 0.985 and 1.0
                    final scale = 0.985 + _pulseAnim.value * 0.015;
                    return Column(
                      children: [
                        Expanded(
                          child: Transform.scale(
                            scale: scale,
                            child: Card(
                              child: FeatureCard(
                                icon: Icons.location_searching,
                                title: l10n.searchClinics,
                                subtitle: l10n.searchClinicsDesc,
                                color: AppColors.blue,
                                chipBg: AppColors.blueBg,
                                onTap: () => context.go('/map'),
                                isAccessible: isAccessible,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Transform.scale(
                            scale: scale,
                            child: Card(
                              child: FeatureCard(
                                icon: Icons.person_pin_circle_outlined,
                                title: l10n.visitPatient,
                                subtitle: l10n.visitPatientDesc,
                                color: AppColors.purple,
                                chipBg: AppColors.purpleBg,
                                onTap: () => context.go('/visitor'),
                                isAccessible: isAccessible,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Transform.scale(
                            scale: scale,
                            child: Card(
                              child: FeatureCard(
                                icon: Icons.event_note_outlined,
                                title: l10n.myAppointments,
                                subtitle: l10n.myAppointmentsDesc,
                                color: AppColors.green,
                                chipBg: AppColors.greenBg,
                                onTap: () => context.go('/appointments'),
                                isAccessible: isAccessible,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Transform.scale(
                            scale: scale,
                            child: Card(
                              child: FeatureCard(
                                icon: Icons.local_hospital_outlined,
                                title: l10n.emergency,
                                subtitle: l10n.quickRouteToER,
                                color: AppColors.red,
                                chipBg: AppColors.redBg,
                                onTap: () => context.go('/emergency'),
                                isAccessible: isAccessible,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: activeText),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
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
