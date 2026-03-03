import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../features/map/painters/navigation_path_painter.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/settings_provider.dart';
import '../painters/floor_plans/floor_plan_painter.dart';

class NavigationMapWidget extends ConsumerStatefulWidget {
  final Destination? initialDestination;
  final Destination? destination;
  final bool isEmergency;
  final bool showSearchBar;
  final double? height;

  const NavigationMapWidget({
    super.key,
    this.initialDestination,
    this.destination,
    this.isEmergency = false,
    this.showSearchBar = false,
    this.height,
  });

  @override
  ConsumerState<NavigationMapWidget> createState() =>
      _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends ConsumerState<NavigationMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _pathController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  Destination? _resolveDestination() {
    return widget.destination ??
        widget.initialDestination ??
        ref.watch(selectedDestinationProvider);
  }

  @override
  void didUpdateWidget(covariant NavigationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldDest = oldWidget.destination ?? oldWidget.initialDestination;
    final newDest = widget.destination ?? widget.initialDestination;
    if (oldDest != newDest && newDest != null) {
      _pathController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospital = ref.watch(selectedHospitalProvider);
    final settings = ref.watch(settingsProvider);
    final dest = _resolveDestination();
    final int floorId = dest?.floor ?? ref.watch(selectedFloorProvider);
    final floor = hospital.floorById(floorId);
    final isDark = settings.darkMode;

    if (floor == null) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('Floor not found')),
      );
    }

    if (dest != null &&
        !_pathController.isAnimating &&
        _pathController.value == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pathController.forward();
      });
    }

    final mapContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isEmergency
              ? AppColors.red.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: getFloorPlanPainter(
                hospitalId: hospital.id,
                floorId: floorId,
                darkMode: settings.darkMode,
                locale: settings.language,
              ),
            ),
          ),
          if (dest != null && dest.floor == floorId)
            Positioned.fill(
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([_pathController, _pulseController]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: NavigationPathPainter(
                      entrance: floor.entrance,
                      destination: dest.position,
                      progress: _pathController.value,
                      pulseValue: _pulseController.value,
                      isEmergency: widget.isEmergency,
                      isAccessibility: settings.accessibilityMode,
                      darkMode: settings.darkMode,
                    ),
                  );
                },
              ),
            ),
          if (dest != null &&
              dest.floor == floorId &&
              _pathController.value >= 1.0)
            _buildRouteInfo(floor, dest, settings),
        ],
      ),
    );

    if (widget.height != null) {
      return SizedBox(height: widget.height, child: mapContent);
    }
    return mapContent;
  }

  Widget _buildRouteInfo(Floor floor, Destination dest, SettingsState settings) {
    final route = calculateRouteInfo(floor.entrance, dest.position);
    final isDark = settings.darkMode;
    final accentColor = widget.isEmergency ? AppColors.red : (isDark ? AppColors.darkBlue : AppColors.blue);

    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: AnimatedOpacity(
        opacity: _pathController.value >= 1.0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _metric(Icons.straighten, '${route.distanceMeters}m', accentColor, isDark),
              Container(
                width: 1,
                height: 20,
                color: isDark ? AppColors.darkDivider : AppColors.divider,
              ),
              _metric(Icons.directions_walk, '${route.walkMinutes} min', accentColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String text, Color accentColor, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: accentColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
