import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../shared/widgets/back_button.dart';
import '../../shared/widgets/navigation_map_widget.dart';
import '../../core/l10n/l10n_utils.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  bool _isNavigating = false;
  late AnimationController _pulseAnim;
  Destination? _erDestination;

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
        setState(() => _erDestination = er);
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Emergency header — clean with red chip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Spacer(),
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
                                Text(
                                  l10n.emergencyMode,
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isAccessible ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Pulsing icon
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, _) {
                            return Container(
                              padding: EdgeInsets.all(18 + _pulseAnim.value * 4),
                              decoration: BoxDecoration(
                                color: AppColors.redBg,
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                              ),
                              child: Icon(
                                Icons.local_hospital_outlined,
                                size: isAccessible ? 48 : 40,
                                color: AppColors.red,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.emergencyRouteInfo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isAccessible ? 15 : 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Route info card
                        if (routeInfo != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          localizeNumber(routeInfo.distanceMeters, settings.language),
                                          style: TextStyle(
                                            fontSize: isAccessible ? 34 : 30,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.red,
                                          ),
                                        ),
                                        Text(
                                          l10n.meters,
                                          style: TextStyle(
                                            fontSize: isAccessible ? 13 : 12,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          localizeNumber(routeInfo.walkMinutes, settings.language),
                                          style: TextStyle(
                                            fontSize: isAccessible ? 34 : 30,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.red,
                                          ),
                                        ),
                                        Text(
                                          l10n.minutes,
                                          style: TextStyle(
                                            fontSize: isAccessible ? 13 : 12,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

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
                            title: Text(l10n.call997, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 16 : 14)),
                            subtitle: Text(l10n.emergencyContact, style: TextStyle(fontSize: isAccessible ? 13 : 11)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Map
                        if (_isNavigating && _erDestination != null)
                          NavigationMapWidget(
                            destination: _erDestination,
                            isEmergency: true,
                            height: 280,
                          ),

                        if (_isNavigating) const SizedBox(height: 12),

                        // Instructions
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.emergencyInstructions,
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 16 : 14),
                                ),
                                const SizedBox(height: 12),
                                _InstructionStep(number: '1', text: l10n.instruction1, isAccessible: isAccessible),
                                const SizedBox(height: 8),
                                _InstructionStep(number: '2', text: l10n.instruction2, isAccessible: isAccessible),
                                const SizedBox(height: 8),
                                _InstructionStep(number: '3', text: l10n.instruction3, isAccessible: isAccessible),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Warning — Notion yellow tag style
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.yellowBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.report_problem_outlined, color: AppColors.yellow, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.emergencyWarning,
                                  style: TextStyle(
                                    fontSize: isAccessible ? 13 : 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Sticky navigation button
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _isNavigating = !_isNavigating);
                  },
                  icon: Icon(
                    _isNavigating ? Icons.close : Icons.navigation_outlined,
                    size: 20,
                  ),
                  label: Text(
                    _isNavigating ? l10n.endNavigation : l10n.startNavigation,
                    style: TextStyle(
                      fontSize: isAccessible ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
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
        ),
      ),
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
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.redBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF000000), width: 1.5),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w600,
              fontSize: isAccessible ? 13 : 11,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: isAccessible ? 14 : 13),
          ),
        ),
      ],
    );
  }
}
