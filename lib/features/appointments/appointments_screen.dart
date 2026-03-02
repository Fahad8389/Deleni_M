import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/hospital.dart';
import '../../data/models/appointment.dart';
import '../../providers/settings_provider.dart';
import '../../providers/hospital_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../shared/widgets/back_button.dart';
import '../../shared/widgets/accessibility_banner.dart';
import '../../shared/widgets/navigation_map_widget.dart';
import '../../core/l10n/l10n_utils.dart';
import 'widgets/create_appointment_sheet.dart';
import 'widgets/appointment_card.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  Appointment? _navigatingTo;

  void _showCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateAppointmentSheet(),
    );
  }

  void _navigateToAppointment(Appointment appointment) {
    final repo = ref.read(hospitalRepositoryProvider);
    final dest = repo.findDestinationById(appointment.destinationId);
    if (dest != null) {
      final hospital = repo.getById(appointment.hospitalId);
      if (hospital != null) {
        ref.read(settingsProvider.notifier).setDefaultHospitalId(hospital.id);
        ref.read(selectedFloorProvider.notifier).state = dest.floor;
        ref.read(selectedDestinationProvider.notifier).state = dest;
      }
    }
    setState(() => _navigatingTo = appointment);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final appointmentsAsync = ref.watch(appointmentProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final selectedDest = ref.watch(selectedDestinationProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AccessibilityBanner(),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  AppBackButton(
                    onPressed: _navigatingTo != null
                        ? () => setState(() => _navigatingTo = null)
                        : () => context.go('/'),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_month_rounded, color: AppColors.datePalmGreen, size: isAccessible ? 28 : 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.myAppointments,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: isAccessible ? 22 : 18,
                    ),
                  ),
                  const Spacer(),
                  if (_navigatingTo == null)
                    IconButton(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.datePalmGreen,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _navigatingTo != null
                  ? _buildNavigationView(settings, l10n, isAccessible, selectedDest)
                  : _buildListView(appointmentsAsync, settings, l10n, isAccessible),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationView(
    SettingsState settings,
    AppLocalizations l10n,
    bool isAccessible,
    Destination? selectedDest,
  ) {
    final routeInfo = ref.watch(routeInfoProvider);
    final repo = ref.read(hospitalRepositoryProvider);
    final dest = repo.findDestinationById(_navigatingTo!.destinationId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (dest != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.datePalmGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: AppColors.datePalmGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.name.get(settings.language),
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: isAccessible ? 17 : 15),
                          ),
                          Text(
                            '${localizeDate(DateTime.parse(_navigatingTo!.date), settings.language)} • ${localizeTime(_navigatingTo!.time, settings.language)}',
                            style: TextStyle(fontSize: isAccessible ? 13 : 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    if (routeInfo != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${localizeNumber(routeInfo.distanceMeters, settings.language)} ${l10n.meters}',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: isAccessible ? 17 : 15, color: AppColors.datePalmGreen),
                          ),
                          Text(
                            '${localizeNumber(routeInfo.walkMinutes, settings.language)} ${l10n.minutes}',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          NavigationMapWidget(
            destination: selectedDest,
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    AsyncValue<List<Appointment>> appointmentsAsync,
    SettingsState settings,
    AppLocalizations l10n,
    bool isAccessible,
  ) {
    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: isAccessible ? 72 : 56,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noAppointments,
                  style: TextStyle(
                    fontSize: isAccessible ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noAppointmentsDesc,
                  style: TextStyle(
                    fontSize: isAccessible ? 15 : 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showCreateSheet,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createAppointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.datePalmGreen,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
