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

class _VisitorScreenState extends ConsumerState<VisitorScreen>
    with SingleTickerProviderStateMixin {
  final _roomController = TextEditingController();
  final _roomFocusNode = FocusNode();
  late AnimationController _pulseAnim;

  bool _showMap = false;
  String? _errorMessage;
  Destination? _foundDestination;
  int? _userFloor;

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
    _roomController.dispose();
    _roomFocusNode.dispose();
    super.dispose();
  }

  void _findRoom(String roomInput) {
    final trimmed = roomInput.trim();
    if (trimmed.isEmpty) return;
    final query = trimmed.toLowerCase();
    final lang = ref.read(settingsProvider).language;

    // Search across all hospitals: room number, name (EN/AR), and destination ID
    final repo = ref.read(hospitalRepositoryProvider);
    for (final hospital in repo.getAll()) {
      for (final dest in hospital.allDestinations) {
        final roomMatch = dest.roomNumber?.toLowerCase() == query;
        final nameEnMatch = dest.name.en.toLowerCase().contains(query);
        final nameArMatch = dest.name.ar.contains(trimmed);
        final idMatch = dest.id.toLowerCase().contains(query);

        if (roomMatch || nameEnMatch || nameArMatch || idMatch) {
          // Switch to this hospital if different
          ref.read(settingsProvider.notifier).setDefaultHospitalId(hospital.id);
          setState(() {
            _errorMessage = null;
            _foundDestination = dest;
          });
          _showFloorPicker(dest, hospital);
          return;
        }
      }
    }

    setState(() {
      _errorMessage = AppLocalizations(lang).roomNotFound;
    });
  }

  void _showFloorPicker(Destination dest, Hospital hospital) {
    final settings = ref.read(settingsProvider);
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
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: subtitleColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.purpleBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: const Icon(Icons.meeting_room_outlined, color: AppColors.purple, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dest.name.get(lang),
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
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
              Text(
                l10n.whichFloorAreYouOn,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 12),
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
                        setState(() {
                          _userFloor = f.id;
                          _showMap = true;
                        });
                        ref.read(selectedFloorProvider.notifier).state = f.id;
                        ref.read(selectedDestinationProvider.notifier).state = dest;
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.layers_outlined, size: 20,
                              color: isDestFloor ? (isDark ? AppColors.darkBlue : AppColors.blue) : subtitleColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(f.name.get(lang),
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                            ),
                            if (isDestFloor)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.5),
                                ),
                                child: Text(l10n.destination,
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.purple)),
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

  void _resetToInput() {
    ref.read(selectedDestinationProvider.notifier).state = null;
    setState(() {
      _showMap = false;
      _errorMessage = null;
      _foundDestination = null;
      _userFloor = null;
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
    final baseFontSize = isAccessibility ? 1.15 : 1.0;

    return Directionality(
      textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: _showMap
              ? _buildMapMode(loc: loc, isDark: isDark, lang: lang, baseFontSize: baseFontSize)
              : _buildInputMode(loc: loc, isDark: isDark, lang: lang, baseFontSize: baseFontSize),
        ),
      ),
    );
  }

  Widget _buildInputMode({
    required AppLocalizations loc,
    required bool isDark,
    required String lang,
    required double baseFontSize,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Back button
        Align(
          alignment: loc.isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: IconButton(
            onPressed: () => context.go('/'),
            icon: Icon(
              loc.isArabic ? Icons.arrow_forward : Icons.arrow_back,
              size: 24,
            ),
            tooltip: loc.back,
          ),
        ),

        const SizedBox(height: 24),

        // Pulsing icon — like emergency screen
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) {
            return Container(
              padding: EdgeInsets.all(16 + _pulseAnim.value * 4),
              decoration: BoxDecoration(
                color: AppColors.purpleBg,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
              ),
              child: Icon(
                Icons.person_pin_circle_outlined,
                color: AppColors.purple,
                size: baseFontSize > 1.0 ? 44 : 36,
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            loc.visitorModeTitle,
            style: TextStyle(
              fontSize: 24 * baseFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // Description
        Center(
          child: Text(
            loc.visitorModeDesc,
            style: TextStyle(
              fontSize: 14 * baseFontSize,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 28),

        // Room number input card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.enterRoomNumber,
                  style: TextStyle(
                    fontSize: 13 * baseFontSize,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _roomController,
                  focusNode: _roomFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _findRoom,
                  style: TextStyle(
                    fontSize: 24 * baseFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '101',
                    hintStyle: TextStyle(
                      fontSize: 24 * baseFontSize,
                      fontWeight: FontWeight.w400,
                      color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                          .withValues(alpha: 0.4),
                      letterSpacing: 2,
                    ),
                    prefixIcon: Icon(
                      Icons.meeting_room_outlined,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Error
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 13 * baseFontSize,
                                color: AppColors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Find Room button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _findRoom(_roomController.text),
                    icon: const Icon(Icons.search, size: 20),
                    label: Text(
                      loc.findRoom,
                      style: TextStyle(
                        fontSize: 14 * baseFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Quick access chips
        Text(
          loc.quickAccess,
          style: TextStyle(
            fontSize: 12 * baseFontSize,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickChip(label: '101', icon: Icons.meeting_room_outlined),
            _QuickChip(label: '201', icon: Icons.meeting_room_outlined),
            _QuickChip(label: '202', icon: Icons.meeting_room_outlined),
          ].map((chip) {
            return ActionChip(
              label: Text(
                chip.label,
                style: TextStyle(
                  fontSize: 13 * baseFontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkBlue : AppColors.blue,
                ),
              ),
              avatar: Icon(
                chip.icon,
                size: 16,
                color: isDark ? AppColors.darkBlue : AppColors.blue,
              ),
              backgroundColor: isDark ? AppColors.darkHighlight : AppColors.blueBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onPressed: () {
                _roomController.text = chip.label;
                _findRoom(chip.label);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // Instructions card — like emergency screen
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.howItWorks,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14 * baseFontSize),
                ),
                const SizedBox(height: 12),
                _VisitorStep(number: '1', text: loc.visitorStep1, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '2', text: loc.visitorStep2, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '3', text: loc.visitorStep3, baseFontSize: baseFontSize),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tip banner — like emergency warning
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purpleBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.purple, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.visitorTip,
                  style: TextStyle(
                    fontSize: 12 * baseFontSize,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMapMode({
    required AppLocalizations loc,
    required bool isDark,
    required String lang,
    required double baseFontSize,
  }) {
    final roomLabel = _foundDestination?.roomNumber ?? '';
    final hospital = ref.watch(selectedHospitalProvider);
    final floorName = _foundDestination != null
        ? hospital.floors
            .where((f) => f.id == _foundDestination!.floor)
            .map((f) => f.name.get(lang))
            .firstOrNull ?? ''
        : '';
    final borderColor = isDark ? Colors.white : const Color(0xFF000000);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Header row — back + search again
        Row(
          children: [
            IconButton(
              onPressed: _resetToInput,
              icon: Icon(
                loc.isArabic ? Icons.arrow_forward : Icons.arrow_back,
                size: 24,
              ),
              tooltip: loc.back,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _resetToInput,
              icon: const Icon(Icons.search, size: 16),
              label: Text(
                loc.searchAgain,
                style: TextStyle(fontSize: 13 * baseFontSize, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Patient Room Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: borderColor, width: 1.75),
                  ),
                  child: const Icon(Icons.meeting_room_outlined, color: AppColors.purple, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomLabel.isNotEmpty
                            ? '${loc.roomNumber}$roomLabel'
                            : _foundDestination?.name.get(lang) ?? '',
                        style: TextStyle(
                          fontSize: 16 * baseFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_foundDestination != null && roomLabel.isNotEmpty)
                        Text(
                          _foundDestination!.name.get(lang),
                          style: TextStyle(
                            fontSize: 13 * baseFontSize,
                            color: isDark ? AppColors.darkBlue : AppColors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        '$floorName • ${hospital.name.get(lang)}',
                        style: TextStyle(
                          fontSize: 12 * baseFontSize,
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

        // Visiting Hours Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18, color: AppColors.green),
                    const SizedBox(width: 8),
                    Text(
                      loc.visitingHours,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * baseFontSize),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Morning
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.green),
                      const SizedBox(width: 10),
                      Text(
                        loc.morningVisit,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13 * baseFontSize,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        loc.morningHours,
                        style: TextStyle(
                          fontSize: 13 * baseFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Evening
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.blueBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.nightlight_outlined, size: 18, color: isDark ? AppColors.darkBlue : AppColors.blue),
                      const SizedBox(width: 10),
                      Text(
                        loc.eveningVisit,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13 * baseFontSize,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        loc.eveningHours,
                        style: TextStyle(
                          fontSize: 13 * baseFontSize,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkBlue : AppColors.blue,
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

        // Visiting Rules Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rule_outlined, size: 18, color: AppColors.red),
                    const SizedBox(width: 8),
                    Text(
                      loc.visitingRules,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * baseFontSize),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _VisitorStep(number: '1', text: loc.visitRule1, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '2', text: loc.visitRule2, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '3', text: loc.visitRule3, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '4', text: loc.visitRule4, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '5', text: loc.visitRule5, baseFontSize: baseFontSize),
                const SizedBox(height: 8),
                _VisitorStep(number: '6', text: loc.visitRule6, baseFontSize: baseFontSize),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Navigate to Room button + Map
        Text(
          loc.navigateToRoom,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14 * baseFontSize),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NavigationMapWidget(showSearchBar: false, userFloor: _userFloor),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _VisitorStep extends StatelessWidget {
  final String number;
  final String text;
  final double baseFontSize;

  const _VisitorStep({
    required this.number,
    required this.text,
    this.baseFontSize = 1.0,
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
            color: AppColors.purpleBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF000000), width: 1.5),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: AppColors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 11 * baseFontSize,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13 * baseFontSize),
          ),
        ),
      ],
    );
  }
}

class _QuickChip {
  final String label;
  final IconData icon;
  const _QuickChip({required this.label, required this.icon});
}
