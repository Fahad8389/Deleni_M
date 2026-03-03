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
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
    final isDark = settings.darkMode;

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
                  Text(
                    l10n.myAppointments,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: isAccessible ? 20 : 17,
                    ),
                  ),
                  const Spacer(),
                  if (_navigatingTo == null)
                    IconButton(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkBlue : AppColors.blue,
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
    final isDark = settings.darkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (dest != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: AppColors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dest.name.get(settings.language),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 14),
                          ),
                          Text(
                            '${localizeDate(DateTime.parse(_navigatingTo!.date), settings.language)} • ${localizeTime(_navigatingTo!.time, settings.language)}',
                            style: Theme.of(context).textTheme.bodySmall,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isAccessible ? 15 : 14,
                              color: isDark ? AppColors.darkBlue : AppColors.blue,
                            ),
                          ),
                          Text(
                            '${localizeNumber(routeInfo.walkMinutes, settings.language)} ${l10n.minutes}',
                            style: Theme.of(context).textTheme.bodySmall,
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
    final isDark = settings.darkMode;

    return appointmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkHighlight : AppColors.highlight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    size: isAccessible ? 48 : 40,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noAppointments,
                  style: TextStyle(
                    fontSize: isAccessible ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.noAppointmentsDesc,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _showCreateSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.createAppointment),
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
