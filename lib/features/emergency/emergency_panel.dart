import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../core/l10n/l10n_utils.dart';

class EmergencyPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const EmergencyPanel({super.key, required this.onClose});

  @override
  ConsumerState<EmergencyPanel> createState() => _EmergencyPanelState();
}

class _EmergencyPanelState extends ConsumerState<EmergencyPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hospital = ref.read(selectedHospitalProvider);
      final er = hospital.emergencyDestination;
      if (er != null) {
        ref.read(selectedFloorProvider.notifier).state = er.floor;
        ref.read(selectedDestinationProvider.notifier).state = er;
      }
    });
  }

  @override
  void dispose() {
    _pulseAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final routeInfo = ref.watch(routeInfoProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final isDark = settings.darkMode;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Pulsing emergency chip
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.redBg.withValues(alpha: 0.6 + _pulseAnim.value * 0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_hospital_outlined, color: AppColors.red, size: isAccessible ? 18 : 16),
                        const SizedBox(width: 6),
                        Text(l10n.emergencyMode,
                          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600,
                            fontSize: isAccessible ? 14 : 12)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Pulsing icon
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return Container(
                    padding: EdgeInsets.all(16 + _pulseAnim.value * 4),
                    decoration: BoxDecoration(
                      color: AppColors.redBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: Icon(Icons.local_hospital_outlined,
                      size: isAccessible ? 40 : 34, color: AppColors.red),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(l10n.emergencyRouteInfo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isAccessible ? 14 : 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 12),

              // Route info
              if (routeInfo != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(localizeNumber(routeInfo.distanceMeters, settings.language),
                                style: TextStyle(fontSize: isAccessible ? 28 : 24,
                                  fontWeight: FontWeight.w600, color: AppColors.red)),
                              Text(l10n.meters,
                                style: TextStyle(fontSize: isAccessible ? 12 : 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40,
                          color: isDark ? AppColors.darkDivider : AppColors.divider),
                        Expanded(
                          child: Column(
                            children: [
                              Text(localizeNumber(routeInfo.walkMinutes, settings.language),
                                style: TextStyle(fontSize: isAccessible ? 28 : 24,
                                  fontWeight: FontWeight.w600, color: AppColors.red)),
                              Text(l10n.minutes,
                                style: TextStyle(fontSize: isAccessible ? 12 : 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              // Emergency contact
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.redBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: const Icon(Icons.phone_in_talk, color: AppColors.red),
                  ),
                  title: Text(l10n.call997,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 13)),
                  subtitle: Text(l10n.emergencyContact,
                    style: TextStyle(fontSize: isAccessible ? 12 : 10)),
                ),
              ),
              const SizedBox(height: 10),

              // Instructions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.emergencyInstructions,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 14 : 13)),
                      const SizedBox(height: 10),
                      _InstructionStep(number: '1', text: l10n.instruction1, isAccessible: isAccessible),
                      const SizedBox(height: 6),
                      _InstructionStep(number: '2', text: l10n.instruction2, isAccessible: isAccessible),
                      const SizedBox(height: 6),
                      _InstructionStep(number: '3', text: l10n.instruction3, isAccessible: isAccessible),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellowBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, color: AppColors.yellow, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.emergencyWarning,
                        style: TextStyle(fontSize: isAccessible ? 12 : 11, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        // Sticky navigation button
        Positioned(
          left: 14, right: 14, bottom: 12,
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.navigation_outlined, size: 18),
              label: Text(
                l10n.startNavigation,
                style: TextStyle(fontSize: isAccessible ? 14 : 13, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  final bool isAccessible;

  const _InstructionStep({
    required this.number,
    required this.text,
    this.isAccessible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20, height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.redBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF000000), width: 1.5),
          ),
          child: Text(number,
            style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600,
              fontSize: isAccessible ? 12 : 10)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: isAccessible ? 13 : 12)),
        ),
      ],
    );
  }
}
