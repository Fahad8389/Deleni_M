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

    // Auto-select ER destination
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Emergency header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(color: AppColors.terracotta.withOpacity(0.2)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withOpacity(0.1 + _pulseAnim.value * 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.terracotta.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emergency_rounded, color: AppColors.terracotta, size: isAccessible ? 20 : 16),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.emergencyMode,
                                  style: TextStyle(
                                    color: AppColors.terracotta,
                                    fontWeight: FontWeight.w800,
                                    fontSize: isAccessible ? 15 : 13,
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
                        // Animated emergency icon
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, _) {
                            return Container(
                              padding: EdgeInsets.all(20 + _pulseAnim.value * 4),
                              decoration: BoxDecoration(
                                color: AppColors.terracotta.withOpacity(0.08 + _pulseAnim.value * 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.emergency_rounded,
                                size: isAccessible ? 56 : 44,
                                color: AppColors.terracotta,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.emergencyRouteInfo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isAccessible ? 16 : 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Route info
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
                                            fontSize: isAccessible ? 36 : 32,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.terracotta,
                                          ),
                                        ),
                                        Text(
                                          l10n.meters,
                                          style: TextStyle(
                                            fontSize: isAccessible ? 14 : 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 50,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          localizeNumber(routeInfo.walkMinutes, settings.language),
                                          style: TextStyle(
                                            fontSize: isAccessible ? 36 : 32,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.terracotta,
                                          ),
                                        ),
                                        Text(
                                          l10n.minutes,
                                          style: TextStyle(
                                            fontSize: isAccessible ? 14 : 12,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                                color: AppColors.terracotta.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone, color: AppColors.terracotta),
                            ),
                            title: Text(l10n.call997, style: TextStyle(fontWeight: FontWeight.w700, fontSize: isAccessible ? 17 : 15)),
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
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: isAccessible ? 17 : 15),
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

                        // Warning
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.gold),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.emergencyWarning,
                                  style: TextStyle(
                                    fontSize: isAccessible ? 13 : 11,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // Space for sticky button
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
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _isNavigating = !_isNavigating);
                      },
                      icon: Icon(
                        _isNavigating ? Icons.close : Icons.navigation_rounded,
                        size: 24,
                      ),
                      label: Text(
                        _isNavigating ? l10n.endNavigation : l10n.startNavigation,
                        style: TextStyle(
                          fontSize: isAccessible ? 18 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terracotta,
                        foregroundColor: Colors.white,
                        elevation: 4 + _pulseAnim.value * 4,
                        shadowColor: AppColors.terracotta.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                },
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
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.terracotta.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: AppColors.terracotta,
              fontWeight: FontWeight.w700,
              fontSize: isAccessible ? 14 : 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: isAccessible ? 15 : 13),
          ),
        ),
      ],
    );
  }
}
