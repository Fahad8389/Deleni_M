import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../data/datasources/hospital_data.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../shared/widgets/navigation_map_widget.dart';

// ── Icon + color helpers ─────────────────────────────────────────────────────

IconData _iconForType(DestinationType type) {
  switch (type) {
    case DestinationType.clinic:
      return Icons.monitor_heart_outlined;
    case DestinationType.department:
      return Icons.grid_view_rounded;
    case DestinationType.room:
      return Icons.meeting_room_outlined;
    case DestinationType.emergency:
      return Icons.local_hospital_outlined;
  }
}

Color _colorForType(DestinationType type) {
  switch (type) {
    case DestinationType.clinic:
      return AppColors.blue;
    case DestinationType.department:
      return AppColors.green;
    case DestinationType.room:
      return AppColors.orange;
    case DestinationType.emergency:
      return AppColors.red;
  }
}

Color _chipBgForType(DestinationType type) {
  switch (type) {
    case DestinationType.clinic:
      return AppColors.blueBg;
    case DestinationType.department:
      return AppColors.greenBg;
    case DestinationType.room:
      return AppColors.orangeBg;
    case DestinationType.emergency:
      return AppColors.redBg;
  }
}

// ── Main screen ──────────────────────────────────────────────────────────────

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  bool _panelExpanded = true;
  int? _userFloor; // The floor the user selected as their physical location

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    setState(() => _showSearchResults = query.isNotEmpty);
  }

  void _selectDestination(Destination dest) {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() => _showSearchResults = false);

    // Always ask which floor the user is on
    _showFloorPicker(dest);
  }

  void _showFloorPicker(Destination dest) {
    final settings = ref.read(settingsProvider);
    final hospital = ref.read(selectedHospitalProvider);
    final lang = settings.language;
    final l10n = AppLocalizations(lang);
    final isDark = settings.darkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;

    final destFloor = hospital.floorById(dest.floor);
    final destFloorName = destFloor?.name.get(lang) ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtitleColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Destination info
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _chipBgForType(dest.type),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: Icon(
                      _iconForType(dest.type),
                      color: _colorForType(dest.type),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name.get(lang),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: textColor,
                          ),
                        ),
                        Text(
                          l10n.destinationOnFloor(destFloorName),
                          style: TextStyle(fontSize: 12, color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Question
              Text(
                l10n.whichFloorAreYouOn,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              // Floor options
              ...hospital.floors.map((f) {
                final isDestFloor = f.id == dest.floor;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: isDestFloor
                        ? (isDark ? AppColors.darkHighlight : AppColors.highlight)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pop(ctx);
                        // Record which floor the user is on
                        setState(() {
                          _userFloor = f.id;
                          _panelExpanded = false;
                        });
                        // Set selected floor to user's floor so map shows their starting point
                        ref.read(selectedFloorProvider.notifier).state = f.id;
                        // Set destination — NavigationMapWidget will handle cross-floor animation
                        ref.read(selectedDestinationProvider.notifier).state = dest;
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 20,
                              color: isDestFloor
                                  ? (isDark ? AppColors.darkBlue : AppColors.blue)
                                  : subtitleColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                f.name.get(lang),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (isDestFloor)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _chipBgForType(dest.type),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.5),
                                ),
                                child: Text(
                                  l10n.navigateTo,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _colorForType(dest.type),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _onHospitalChanged(String? hospitalId) {
    if (hospitalId == null) return;
    ref.read(settingsProvider.notifier).setDefaultHospitalId(hospitalId);
    ref.read(selectedFloorProvider.notifier).state = 0;
    ref.read(selectedDestinationProvider.notifier).state = null;
    ref.read(searchQueryProvider.notifier).state = '';
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final hospital = ref.watch(selectedHospitalProvider);
    final allHospitals = ref.watch(hospitalsProvider);
    final floorIndex = ref.watch(selectedFloorProvider);
    final selectedDest = ref.watch(selectedDestinationProvider);
    final filteredDests = ref.watch(filteredDestinationsProvider);

    final isDark = settings.darkMode;
    final lang = settings.language;
    final l10n = AppLocalizations(lang);
    final isRtl = l10n.isArabic;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;

    final currentFloor = hospital.floorById(floorIndex) ?? hospital.floors.first;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // ── Map — fills entire screen ──
              Positioned.fill(
                child: NavigationMapWidget(
                  showSearchBar: false,
                  userFloor: _userFloor,
                ),
              ),

              // ── Floating search bar ──
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Back arrow button
                        GestureDetector(
                          onTap: () => context.go('/'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRtl ? Icons.arrow_forward : Icons.arrow_back,
                              color: textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Search pill
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    onChanged: _onSearchChanged,
                                    style: TextStyle(color: textColor, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: l10n.searchDestination,
                                      hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        left: isRtl ? 12 : 16,
                                        right: isRtl ? 16 : 12,
                                        top: 10,
                                        bottom: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(Icons.close, color: subtitleColor, size: 18),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Search results dropdown
                    if (_showSearchResults && filteredDests.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _buildSearchResults(
                          filteredDests, lang, isDark, textColor,
                          subtitleColor, cardColor, dividerColor,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Bottom panel — collapsible ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta != null) {
                      if (details.primaryDelta! < -6 && !_panelExpanded) {
                        setState(() => _panelExpanded = true);
                      } else if (details.primaryDelta! > 6 && _panelExpanded && selectedDest != null) {
                        setState(() => _panelExpanded = false);
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      border: Border(top: BorderSide(color: dividerColor)),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle — tap to toggle
                        GestureDetector(
                          onTap: () {
                            if (selectedDest != null) {
                              setState(() => _panelExpanded = !_panelExpanded);
                            }
                          },
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 4),
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: subtitleColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        // Selected destination info (always visible when selected)
                        if (selectedDest != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _panelExpanded = !_panelExpanded);
                            },
                            child: _buildSelectedInfo(
                              selectedDest, lang, isDark, textColor, subtitleColor,
                              showExpandHint: !_panelExpanded,
                            ),
                          ),
                        // Floor tabs + destination list (collapsible)
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _panelExpanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFloorTabs(hospital, floorIndex, lang, isDark, textColor, subtitleColor, dividerColor),
                              SizedBox(
                                height: 160,
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: currentFloor.destinations.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1, color: dividerColor, indent: 56,
                                  ),
                                  itemBuilder: (context, index) {
                                    final dest = currentFloor.destinations[index];
                                    final isActive = selectedDest?.id == dest.id;
                                    return _buildDestRow(
                                      dest, isActive, lang, isDark,
                                      textColor, subtitleColor,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selected destination info bar ──

  Widget _buildSelectedInfo(
    Destination dest, String lang, bool isDark,
    Color textColor, Color subtitleColor, {
    bool showExpandHint = false,
  }) {
    final routeInfo = ref.watch(routeInfoProvider);
    final chipColor = _colorForType(dest.type);
    final chipBg = _chipBgForType(dest.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: chipBg,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
            ),
            child: Icon(_iconForType(dest.type), color: chipColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dest.name.get(lang),
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary,
              ),
            ),
          ),
          if (routeInfo != null)
            Text(
              '${routeInfo.distanceMeters}m · ${routeInfo.walkMinutes} min',
              style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13, color: chipColor,
              ),
            ),
          if (showExpandHint)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  // ── Floor tabs ──

  Widget _buildFloorTabs(
    Hospital hospital, int floorIndex, String lang, bool isDark,
    Color textColor, Color subtitleColor, Color dividerColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: hospital.floors.map((f) {
          final isSelected = f.id == floorIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(selectedFloorProvider.notifier).state = f.id;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.darkBlue : AppColors.blue)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  f.name.get(lang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (isDark ? AppColors.darkBlue : AppColors.blue)
                        : subtitleColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Destination row ──

  Widget _buildDestRow(
    Destination dest, bool isActive, String lang, bool isDark,
    Color textColor, Color subtitleColor,
  ) {
    final chipBg = _chipBgForType(dest.type);
    final chipColor = _colorForType(dest.type);

    return InkWell(
      onTap: () => _selectDestination(dest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isActive
            ? (isDark ? AppColors.darkHighlight : AppColors.highlight)
            : null,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
              ),
              child: Icon(_iconForType(dest.type), color: chipColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dest.name.get(lang),
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive)
              Icon(Icons.check_circle, size: 18,
                color: isDark ? AppColors.darkBlue : AppColors.blue)
            else
              Icon(Icons.chevron_right, size: 18, color: subtitleColor),
          ],
        ),
      ),
    );
  }

  // ── Search results dropdown ──

  Widget _buildSearchResults(
    List<Destination> results, String lang, bool isDark,
    Color textColor, Color subtitleColor, Color cardColor, Color dividerColor,
  ) {
    final display = results.take(6).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: display.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: dividerColor, indent: 56),
        itemBuilder: (context, index) {
          final dest = display[index];
          final chipBg = _chipBgForType(dest.type);
          final chipColor = _colorForType(dest.type);
          final floorName = _floorNameForDest(dest, lang);

          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(_iconForType(dest.type), color: chipColor, size: 16),
            ),
            title: Text(
              dest.name.get(lang),
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              floorName,
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, size: 18, color: subtitleColor),
            onTap: () => _selectDestination(dest),
          );
        },
      ),
    );
  }

  String _floorNameForDest(Destination dest, String lang) {
    for (final h in hospitals) {
      for (final f in h.floors) {
        if (f.id == dest.floor) return f.name.get(lang);
      }
    }
    return '';
  }
}
