import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../data/models/appointment.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../core/l10n/l10n_utils.dart';
import 'widgets/create_appointment_sheet.dart';
import 'widgets/appointment_card.dart';

class AppointmentsPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const AppointmentsPanel({super.key, required this.onClose});

  @override
  ConsumerState<AppointmentsPanel> createState() => _AppointmentsPanelState();
}

class _AppointmentsPanelState extends ConsumerState<AppointmentsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseAnim;

  // When non-null, shows the floor picker inside the popup
  Appointment? _selectedAppointment;
  Destination? _selectedDest;
  Hospital? _selectedHospital;

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

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => const CreateAppointmentSheet(),
    );
  }

  void _navigateToAppointment(Appointment appointment) {
    final repo = ref.read(hospitalRepositoryProvider);
    Destination? dest;

    if (appointment.destinationId != null) {
      dest = repo.findDestinationById(appointment.destinationId!);
    }

    if (dest == null && appointment.clinicName.isNotEmpty) {
      final hospital = repo.getById(appointment.hospitalId);
      if (hospital != null) {
        final clinicLower = appointment.clinicName.toLowerCase();
        for (final d in hospital.allDestinations) {
          if (d.name.en.toLowerCase().contains(clinicLower) ||
              d.name.ar.contains(appointment.clinicName)) {
            dest = d;
            break;
          }
        }
      }
    }

    if (dest != null) {
      final hospital = repo.getById(appointment.hospitalId);
      if (hospital != null) {
        ref.read(settingsProvider.notifier).setDefaultHospitalId(hospital.id);
        setState(() {
          _selectedAppointment = appointment;
          _selectedDest = dest;
          _selectedHospital = hospital;
        });
      }
    }
  }

  void _selectFloorAndClose(int floorId) {
    ref.read(selectedFloorProvider.notifier).state = floorId;
    ref.read(selectedDestinationProvider.notifier).state = _selectedDest;
    widget.onClose();
  }

  void _backToList() {
    setState(() {
      _selectedAppointment = null;
      _selectedDest = null;
      _selectedHospital = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final appointmentsAsync = ref.watch(appointmentProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final isDark = settings.darkMode;

    // Show floor picker view inside the popup
    if (_selectedAppointment != null && _selectedDest != null && _selectedHospital != null) {
      return _buildFloorPickerView(settings, l10n, isAccessible, isDark);
    }

    return Column(
      children: [
        // Add button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              onPressed: _showCreateSheet,
              icon: const Icon(Icons.add_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkBlue : AppColors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildListView(appointmentsAsync, settings, l10n, isAccessible),
        ),
      ],
    );
  }

  Widget _buildFloorPickerView(
    SettingsState settings,
    AppLocalizations l10n,
    bool isAccessible,
    bool isDark,
  ) {
    final dest = _selectedDest!;
    final hospital = _selectedHospital!;
    final appointment = _selectedAppointment!;
    final lang = settings.language;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final borderColor = isDark ? Colors.white : const Color(0xFF000000);

    final destFloor = hospital.floorById(dest.floor);
    final destFloorName = destFloor?.name.get(lang) ?? '';
    final displayName = appointment.clinicName.isNotEmpty
        ? appointment.clinicName
        : dest.name.get(lang);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      children: [
        // Back to list
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _backToList,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(l10n.back, style: const TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(height: 6),

        // Appointment info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: borderColor, width: 1.75),
                  ),
                  child: const Icon(Icons.local_hospital_outlined, color: AppColors.green, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 14 : 13)),
                      Text(l10n.destinationOnFloor(destFloorName),
                        style: TextStyle(fontSize: 12, color: subtitleColor)),
                      if (appointment.patientName.isNotEmpty)
                        Text(appointment.patientName,
                          style: TextStyle(
                            color: isDark ? AppColors.darkBlue : AppColors.blue,
                            fontWeight: FontWeight.w600, fontSize: isAccessible ? 12 : 11)),
                      Text(
                        '${localizeDate(DateTime.parse(appointment.date), lang)} • ${localizeTime(appointment.time, lang)}',
                        style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Which floor are you on?
        Text(l10n.whichFloorAreYouOn,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
        const SizedBox(height: 8),
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
                onTap: () => _selectFloorAndClose(f.id),
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
                            color: AppColors.greenBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Text(l10n.destination,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListView(
    AsyncValue<List<Appointment>> appointmentsAsync,
    SettingsState settings,
    AppLocalizations l10n,
    bool isAccessible,
  ) {
    final isDark = settings.darkMode;

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, _) {
                      return Container(
                        padding: EdgeInsets.all(14 + _pulseAnim.value * 4),
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white : const Color(0xFF000000), width: 1.75),
                        ),
                        child: Icon(Icons.event_note_outlined,
                          size: isAccessible ? 40 : 34, color: AppColors.green),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.noAppointments,
                    style: TextStyle(fontSize: isAccessible ? 16 : 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(l10n.noAppointmentsDesc,
                    style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200, height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.addAppointment),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: appointments.length,
          itemBuilder: (context, i) {
            return AppointmentCard(
              appointment: appointments[i],
              onNavigate: () => _navigateToAppointment(appointments[i]),
              onDelete: () => ref.read(appointmentProvider.notifier).remove(appointments[i].id),
            );
          },
        );
      },
    );
  }
}
