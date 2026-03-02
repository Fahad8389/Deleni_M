import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/settings_provider.dart';
import '../../shared/widgets/navigation_map_widget.dart';

class VisitorScreen extends ConsumerStatefulWidget {
  const VisitorScreen({super.key});

  @override
  ConsumerState<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends ConsumerState<VisitorScreen> {
  final _roomController = TextEditingController();
  final _roomFocusNode = FocusNode();

  bool _showMap = false;
  String? _errorMessage;
  Destination? _foundDestination;

  @override
  void dispose() {
    _roomController.dispose();
    _roomFocusNode.dispose();
    super.dispose();
  }

  void _findRoom(String roomInput) {
    final trimmed = roomInput.trim();
    if (trimmed.isEmpty) return;

    final hospital = ref.read(selectedHospitalProvider);
    final match = hospital.allDestinations.where((d) {
      final room = d.roomNumber?.toLowerCase() ?? '';
      return room == trimmed.toLowerCase();
    }).toList();

    if (match.isNotEmpty) {
      final dest = match.first;
      ref.read(selectedDestinationProvider.notifier).state = dest;
      ref.read(selectedFloorProvider.notifier).state = dest.floor;
      setState(() {
        _showMap = true;
        _errorMessage = null;
        _foundDestination = dest;
      });
    } else {
      setState(() {
        _errorMessage =
            AppLocalizations(ref.read(settingsProvider).language).roomNotFound;
      });
    }
  }

  void _resetToInput() {
    ref.read(selectedDestinationProvider.notifier).state = null;
    setState(() {
      _showMap = false;
      _errorMessage = null;
      _foundDestination = null;
      _roomController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = settings.darkMode;
    final lang = settings.language;
    final loc = AppLocalizations(lang);
    final isAccessibility = settings.accessibilityMode;

    final bgColor = isDark ? AppColors.midnightIndigo : AppColors.warmSand;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final subtitleColor =
        isDark ? AppColors.subtitleLight : AppColors.subtitleDark;
    final dividerColor =
        isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final baseFontSize = isAccessibility ? 1.15 : 1.0;

    return Directionality(
      textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: _showMap
              ? _buildMapMode(
                  loc: loc,
                  isDark: isDark,
                  lang: lang,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  dividerColor: dividerColor,
                  bgColor: bgColor,
                  baseFontSize: baseFontSize,
                )
              : _buildInputMode(
                  loc: loc,
                  isDark: isDark,
                  lang: lang,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  dividerColor: dividerColor,
                  bgColor: bgColor,
                  baseFontSize: baseFontSize,
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Input Mode
  // ---------------------------------------------------------------------------
  Widget _buildInputMode({
    required AppLocalizations loc,
    required bool isDark,
    required String lang,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
    required Color bgColor,
    required double baseFontSize,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // -- Back button --
        Align(
          alignment:
              loc.isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Semantics(
            button: true,
            label: loc.back,
            child: IconButton(
              onPressed: () => context.go('/'),
              icon: Icon(
                loc.isArabic ? Icons.arrow_forward : Icons.arrow_back,
                color: textColor,
                size: 26,
              ),
              tooltip: loc.back,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // -- Circular icon badge --
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold.withValues(alpha: 0.85),
                  AppColors.deepTeal.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.people,
              color: Colors.white,
              size: 42,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // -- Title --
        Center(
          child: Text(
            loc.visitorModeTitle,
            style: TextStyle(
              fontSize: 26 * baseFontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // -- Description --
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              loc.visitorModeDesc,
              style: TextStyle(
                fontSize: 14 * baseFontSize,
                color: subtitleColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // -- Room number input card --
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                loc.enterRoomNumber,
                style: TextStyle(
                  fontSize: 14 * baseFontSize,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 12),

              // Text field
              Semantics(
                label: loc.enterRoomNumber,
                child: TextField(
                  controller: _roomController,
                  focusNode: _roomFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _findRoom,
                  style: TextStyle(
                    fontSize: 28 * baseFontSize,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '101',
                    hintStyle: TextStyle(
                      fontSize: 28 * baseFontSize,
                      fontWeight: FontWeight.w400,
                      color: subtitleColor.withValues(alpha: 0.4),
                      letterSpacing: 2,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.midnightIndigo.withValues(alpha: 0.5)
                        : AppColors.warmSand.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.deepTeal,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.meeting_room,
                      color: subtitleColor,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.terracotta,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 13 * baseFontSize,
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Find Room button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Semantics(
                  button: true,
                  label: loc.findRoom,
                  child: ElevatedButton.icon(
                    onPressed: () => _findRoom(_roomController.text),
                    icon: const Icon(Icons.search, size: 22),
                    label: Text(
                      loc.findRoom,
                      style: TextStyle(
                        fontSize: 16 * baseFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // -- Quick access chips --
        Text(
          loc.quickAccess,
          style: TextStyle(
            fontSize: 13 * baseFontSize,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ['101', '102', '201', '202'].map((room) {
            return Semantics(
              button: true,
              label: '${loc.room} $room',
              child: ActionChip(
                label: Text(
                  '${loc.roomNumber}$room',
                  style: TextStyle(
                    fontSize: 14 * baseFontSize,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textLight : AppColors.deepTeal,
                  ),
                ),
                avatar: Icon(
                  Icons.meeting_room,
                  size: 18,
                  color: isDark
                      ? AppColors.gold
                      : AppColors.deepTeal.withValues(alpha: 0.7),
                ),
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.deepTeal.withValues(alpha: 0.08),
                side: BorderSide(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.deepTeal.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () {
                  _roomController.text = room;
                  _findRoom(room);
                },
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Map Mode
  // ---------------------------------------------------------------------------
  Widget _buildMapMode({
    required AppLocalizations loc,
    required bool isDark,
    required String lang,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color dividerColor,
    required Color bgColor,
    required double baseFontSize,
  }) {
    final roomLabel = _foundDestination?.roomNumber ?? '';

    return Column(
      children: [
        // -- Info card at top --
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${loc.navigateTo} ${loc.roomNumber}$roomLabel',
                      style: TextStyle(
                        fontSize: 16 * baseFontSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (_foundDestination != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _foundDestination!.name.get(lang),
                          style: TextStyle(
                            fontSize: 13 * baseFontSize,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Search Again button
              Semantics(
                button: true,
                label: loc.searchAgain,
                child: TextButton.icon(
                  onPressed: _resetToInput,
                  icon: Icon(
                    Icons.search,
                    size: 18,
                    color: isDark ? AppColors.gold : AppColors.deepTeal,
                  ),
                  label: Text(
                    loc.searchAgain,
                    style: TextStyle(
                      fontSize: 13 * baseFontSize,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.gold : AppColors.deepTeal,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: isDark
                        ? AppColors.gold.withValues(alpha: 0.1)
                        : AppColors.deepTeal.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // -- Navigation map --
        const Expanded(
          child: NavigationMapWidget(
            showSearchBar: false,
          ),
        ),
      ],
    );
  }
}
