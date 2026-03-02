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
import '../../shared/widgets/navigation_map_widget.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    setState(() {
      _showSearchResults = query.isNotEmpty;
    });
  }

  void _onDestinationSelected(Destination destination) {
    ref.read(selectedDestinationProvider.notifier).state = destination;
    ref.read(selectedFloorProvider.notifier).state = destination.floor;
    ref.read(searchQueryProvider.notifier).state = '';
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchResults = false;
    });
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

    final bgColor = isDark ? AppColors.midnightIndigo : AppColors.warmSand;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.alabaster;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final subtitleColor =
        isDark ? AppColors.subtitleLight : AppColors.subtitleDark;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final currentFloor =
        hospital.floorById(floorIndex) ?? hospital.floors.first;
    final floorDestinations = currentFloor.destinations;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward : Icons.arrow_back,
              color: textColor,
            ),
            onPressed: () => context.go('/'),
          ),
          title: _HospitalDropdown(
            hospitals: allHospitals,
            selectedId: settings.defaultHospitalId,
            language: lang,
            isDark: isDark,
            textColor: textColor,
            subtitleColor: subtitleColor,
            cardColor: cardColor,
            onChanged: _onHospitalChanged,
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;

              return Column(
                children: [
                  // -- Search bar --
                  _SearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    hintText: l10n.searchDestination,
                    isDark: isDark,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    dividerColor: dividerColor,
                    onChanged: _onSearchChanged,
                  ),

                  // -- Main content --
                  Expanded(
                    child: Stack(
                      children: [
                        if (isWide)
                          Row(
                            children: [
                              // Left sidebar
                              SizedBox(
                                width: 260,
                                child: _Sidebar(
                                  hospital: hospital,
                                  currentFloor: currentFloor,
                                  floorIndex: floorIndex,
                                  selectedDest: selectedDest,
                                  floorDestinations: floorDestinations,
                                  isDark: isDark,
                                  lang: lang,
                                  l10n: l10n,
                                  textColor: textColor,
                                  subtitleColor: subtitleColor,
                                  cardColor: cardColor,
                                  dividerColor: dividerColor,
                                  onFloorSelected: (id) {
                                    ref
                                        .read(selectedFloorProvider.notifier)
                                        .state = id;
                                  },
                                  onDestinationSelected:
                                      _onDestinationSelected,
                                ),
                              ),
                              VerticalDivider(
                                width: 1,
                                color: dividerColor,
                              ),
                              // Map
                              const Expanded(
                                child: NavigationMapWidget(
                                    showSearchBar: false),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              const Expanded(
                                child: NavigationMapWidget(
                                    showSearchBar: false),
                              ),
                              // Bottom panel
                              _BottomPanel(
                                hospital: hospital,
                                currentFloor: currentFloor,
                                floorIndex: floorIndex,
                                selectedDest: selectedDest,
                                floorDestinations: floorDestinations,
                                isDark: isDark,
                                lang: lang,
                                l10n: l10n,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                cardColor: cardColor,
                                dividerColor: dividerColor,
                                onFloorSelected: (id) {
                                  ref
                                      .read(selectedFloorProvider.notifier)
                                      .state = id;
                                },
                                onDestinationSelected:
                                    _onDestinationSelected,
                              ),
                            ],
                          ),

                        // -- Search results overlay --
                        if (_showSearchResults && filteredDests.isNotEmpty)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: _SearchResultsDropdown(
                              results: filteredDests,
                              language: lang,
                              isDark: isDark,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              cardColor: cardColor,
                              dividerColor: dividerColor,
                              onSelected: _onDestinationSelected,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hospital dropdown in app bar
// ---------------------------------------------------------------------------
class _HospitalDropdown extends StatelessWidget {
  final List<Hospital> hospitals;
  final String selectedId;
  final String language;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final ValueChanged<String?> onChanged;

  const _HospitalDropdown({
    required this.hospitals,
    required this.selectedId,
    required this.language,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedId,
        dropdownColor: cardColor,
        icon: Icon(Icons.keyboard_arrow_down, color: subtitleColor, size: 20),
        style: TextStyle(fontSize: 15, color: textColor),
        items: hospitals.map((h) {
          return DropdownMenuItem(
            value: h.id,
            child: Text(
              h.name.get(language),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color dividerColor;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.dividerColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: subtitleColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Icon(Icons.close, color: subtitleColor, size: 18),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search results dropdown overlay
// ---------------------------------------------------------------------------
class _SearchResultsDropdown extends StatelessWidget {
  final List<Destination> results;
  final String language;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color dividerColor;
  final ValueChanged<Destination> onSelected;

  const _SearchResultsDropdown({
    required this.results,
    required this.language,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.dividerColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(language);
    final displayResults = results.take(8).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
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
        itemCount: displayResults.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: dividerColor,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final dest = displayResults[index];
          final floorName = _floorNameForDest(dest, language);

          return ListTile(
            dense: true,
            leading: Icon(
              _iconForType(dest.type),
              color: _colorForType(dest.type),
              size: 20,
            ),
            title: Text(
              dest.name.get(language),
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              [
                if (dest.roomNumber != null)
                  '${l10n.roomNumber}${dest.roomNumber}',
                floorName,
              ].join(' - '),
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
              ),
            ),
            onTap: () => onSelected(dest),
          );
        },
      ),
    );
  }

  String _floorNameForDest(Destination dest, String lang) {
    for (final h in hospitals) {
      for (final f in h.floors) {
        if (f.id == dest.floor) {
          return f.name.get(lang);
        }
      }
    }
    return '';
  }

  IconData _iconForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return Icons.medical_services;
      case DestinationType.department:
        return Icons.business;
      case DestinationType.room:
        return Icons.meeting_room;
      case DestinationType.emergency:
        return Icons.local_hospital;
    }
  }

  Color _colorForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return AppColors.deepTeal;
      case DestinationType.department:
        return AppColors.datePalmGreen;
      case DestinationType.room:
        return AppColors.gold;
      case DestinationType.emergency:
        return AppColors.terracotta;
    }
  }
}

// ---------------------------------------------------------------------------
// Sidebar for wide screens
// ---------------------------------------------------------------------------
class _Sidebar extends StatelessWidget {
  final Hospital hospital;
  final Floor currentFloor;
  final int floorIndex;
  final Destination? selectedDest;
  final List<Destination> floorDestinations;
  final bool isDark;
  final String lang;
  final AppLocalizations l10n;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color dividerColor;
  final ValueChanged<int> onFloorSelected;
  final ValueChanged<Destination> onDestinationSelected;

  const _Sidebar({
    required this.hospital,
    required this.currentFloor,
    required this.floorIndex,
    required this.selectedDest,
    required this.floorDestinations,
    required this.isDark,
    required this.lang,
    required this.l10n,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.dividerColor,
    required this.onFloorSelected,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Floor selector heading
          Text(
            l10n.floor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 8),

          // Floor buttons
          ...hospital.floors.map((f) {
            final isSelected = f.id == floorIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: isSelected
                    ? AppColors.deepTeal.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onFloorSelected(f.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.deepTeal : dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.layers,
                          size: 16,
                          color: isSelected
                              ? AppColors.deepTeal
                              : subtitleColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f.name.get(lang),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppColors.deepTeal
                                  : textColor,
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

          const SizedBox(height: 12),
          Divider(color: dividerColor),
          const SizedBox(height: 8),

          // Selected destination info card
          if (selectedDest != null) ...[
            _DestinationInfoCard(
              destination: selectedDest!,
              language: lang,
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 12),
            Divider(color: dividerColor),
            const SizedBox(height: 8),
          ],

          // Destinations list for current floor
          Text(
            '${currentFloor.name.get(lang)} - ${l10n.destination}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 8),
          ...floorDestinations.map((dest) {
            final isActive = selectedDest?.id == dest.id;
            return _DestinationListTile(
              destination: dest,
              isActive: isActive,
              language: lang,
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
              dividerColor: dividerColor,
              onTap: () => onDestinationSelected(dest),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom panel for mobile / narrow screens
// ---------------------------------------------------------------------------
class _BottomPanel extends StatelessWidget {
  final Hospital hospital;
  final Floor currentFloor;
  final int floorIndex;
  final Destination? selectedDest;
  final List<Destination> floorDestinations;
  final bool isDark;
  final String lang;
  final AppLocalizations l10n;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color dividerColor;
  final ValueChanged<int> onFloorSelected;
  final ValueChanged<Destination> onDestinationSelected;

  const _BottomPanel({
    required this.hospital,
    required this.currentFloor,
    required this.floorIndex,
    required this.selectedDest,
    required this.floorDestinations,
    required this.isDark,
    required this.lang,
    required this.l10n,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.dividerColor,
    required this.onFloorSelected,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
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

          // Selected destination info
          if (selectedDest != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _DestinationInfoCard(
                destination: selectedDest!,
                language: lang,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            ),

          // Horizontally scrollable floor + destination chips
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                // Floor chips
                ...hospital.floors.map((f) {
                  final isSelected = f.id == floorIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(f.name.get(lang)),
                      backgroundColor: isSelected
                          ? AppColors.deepTeal.withValues(alpha: 0.15)
                          : (isDark
                              ? AppColors.darkSurface
                              : Colors.white),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.deepTeal
                            : dividerColor,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.deepTeal
                            : textColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 12,
                      ),
                      onPressed: () => onFloorSelected(f.id),
                    ),
                  );
                }),

                const SizedBox(width: 8),

                // Destination chips for current floor
                ...floorDestinations.map((dest) {
                  final isActive = selectedDest?.id == dest.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(
                        _iconForType(dest.type),
                        size: 16,
                        color: isActive
                            ? Colors.white
                            : _colorForType(dest.type),
                      ),
                      label: Text(
                        dest.name.get(lang),
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? Colors.white : textColor,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      backgroundColor: isActive
                          ? AppColors.deepTeal
                          : (isDark
                              ? AppColors.darkSurface
                              : Colors.white),
                      side: BorderSide(
                        color: isActive
                            ? AppColors.deepTeal
                            : dividerColor,
                      ),
                      onPressed: () => onDestinationSelected(dest),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return Icons.medical_services;
      case DestinationType.department:
        return Icons.business;
      case DestinationType.room:
        return Icons.meeting_room;
      case DestinationType.emergency:
        return Icons.local_hospital;
    }
  }

  Color _colorForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return AppColors.deepTeal;
      case DestinationType.department:
        return AppColors.datePalmGreen;
      case DestinationType.room:
        return AppColors.gold;
      case DestinationType.emergency:
        return AppColors.terracotta;
    }
  }
}

// ---------------------------------------------------------------------------
// Destination info card (shown when a destination is selected)
// ---------------------------------------------------------------------------
class _DestinationInfoCard extends StatelessWidget {
  final Destination destination;
  final String language;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _DestinationInfoCard({
    required this.destination,
    required this.language,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(language);
    final accentColor = destination.type == DestinationType.emergency
        ? AppColors.terracotta
        : AppColors.deepTeal;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _iconForType(destination.type),
            color: accentColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name.get(language),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (destination.roomNumber != null)
                  Text(
                    '${l10n.roomNumber}${destination.roomNumber}',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.navigation,
            color: accentColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  IconData _iconForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return Icons.medical_services;
      case DestinationType.department:
        return Icons.business;
      case DestinationType.room:
        return Icons.meeting_room;
      case DestinationType.emergency:
        return Icons.local_hospital;
    }
  }
}

// ---------------------------------------------------------------------------
// Destination list tile (sidebar)
// ---------------------------------------------------------------------------
class _DestinationListTile extends StatelessWidget {
  final Destination destination;
  final bool isActive;
  final String language;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color dividerColor;
  final VoidCallback onTap;

  const _DestinationListTile({
    required this.destination,
    required this.isActive,
    required this.language,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.dividerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(language);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? AppColors.deepTeal.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _iconForType(destination.type),
                  size: 16,
                  color: isActive
                      ? AppColors.deepTeal
                      : _colorForType(destination.type),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name.get(language),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color:
                              isActive ? AppColors.deepTeal : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (destination.roomNumber != null)
                        Text(
                          '${l10n.roomNumber}${destination.roomNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isActive)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.deepTeal,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return Icons.medical_services;
      case DestinationType.department:
        return Icons.business;
      case DestinationType.room:
        return Icons.meeting_room;
      case DestinationType.emergency:
        return Icons.local_hospital;
    }
  }

  Color _colorForType(DestinationType type) {
    switch (type) {
      case DestinationType.clinic:
        return AppColors.deepTeal;
      case DestinationType.department:
        return AppColors.datePalmGreen;
      case DestinationType.room:
        return AppColors.gold;
      case DestinationType.emergency:
        return AppColors.terracotta;
    }
  }
}
