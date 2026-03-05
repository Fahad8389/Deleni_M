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
          children: ['101', '102', '201', '202'].map((room) {
            return ActionChip(
              label: Text(
                '${loc.roomNumber}$room',
                style: TextStyle(
                  fontSize: 13 * baseFontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkBlue : AppColors.blue,
                ),
              ),
              avatar: Icon(
                Icons.meeting_room_outlined,
                size: 16,
                color: isDark ? AppColors.darkBlue : AppColors.blue,
              ),
              backgroundColor: isDark ? AppColors.darkHighlight : AppColors.blueBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onPressed: () {
                _roomController.text = room;
                _findRoom(room);
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

    return Column(
      children: [
        // Info card at top
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.purpleBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                    ),
                    child: const Icon(Icons.person_pin_circle_outlined, color: AppColors.purple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc.navigateTo} ${loc.roomNumber}$roomLabel',
                          style: TextStyle(
                            fontSize: 15 * baseFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_foundDestination != null)
                          Text(
                            _foundDestination!.name.get(lang),
                            style: TextStyle(
                              fontSize: 13 * baseFontSize,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _resetToInput,
                    child: Text(
                      loc.searchAgain,
                      style: TextStyle(
                        fontSize: 13 * baseFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Expanded(
          child: NavigationMapWidget(showSearchBar: false),
        ),
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
