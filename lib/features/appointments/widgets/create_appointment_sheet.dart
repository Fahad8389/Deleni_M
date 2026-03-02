import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/hospital.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/time_slot.dart';
import '../../../data/datasources/schedule_data.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/hospital_provider.dart';
import '../../../providers/appointment_provider.dart';
import '../../../core/l10n/l10n_utils.dart';

class CreateAppointmentSheet extends ConsumerStatefulWidget {
  const CreateAppointmentSheet({super.key});

  @override
  ConsumerState<CreateAppointmentSheet> createState() => _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends ConsumerState<CreateAppointmentSheet> {
  String? _selectedHospitalId;
  Destination? _selectedClinic;
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedHospitalId = ref.read(settingsProvider).defaultHospitalId;
  }

  List<Destination> _getClinics() {
    if (_selectedHospitalId == null) return [];
    final hospital = ref.read(hospitalRepositoryProvider).getById(_selectedHospitalId!);
    if (hospital == null) return [];
    return hospital.allDestinations.where((d) => d.type == DestinationType.clinic).toList();
  }

  List<TimeSlot> _getSlots() {
    if (_selectedClinic == null || _selectedDate == null) return [];
    return getAvailableSlots(_selectedClinic!.id, _selectedDate!);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.datePalmGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
      });
    }
  }

  void _save() {
    if (_selectedHospitalId == null ||
        _selectedClinic == null ||
        _selectedDate == null ||
        _selectedTime == null) return;

    final appointment = Appointment(
      id: const Uuid().v4(),
      hospitalId: _selectedHospitalId!,
      destinationId: _selectedClinic!.id,
      date: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      time: _selectedTime!,
    );

    ref.read(appointmentProvider.notifier).add(appointment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final hospitals = ref.watch(hospitalsProvider);
    final l10n = AppLocalizations(settings.language);
    final isAccessible = settings.accessibilityMode;
    final clinics = _getClinics();
    final slots = _getSlots();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.createAppointment,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: isAccessible ? 22 : 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Hospital selector
              Text(l10n.selectHospital, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedHospitalId,
                items: hospitals.map((h) => DropdownMenuItem(
                  value: h.id,
                  child: Text(h.name.get(settings.language), style: TextStyle(fontSize: isAccessible ? 15 : 13)),
                )).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedHospitalId = v;
                    _selectedClinic = null;
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Clinic selector
              Text(l10n.selectClinic, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedClinic?.id,
                items: clinics.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    '${c.name.get(settings.language)}${c.roomNumber != null ? ' (${c.roomNumber})' : ''}',
                    style: TextStyle(fontSize: isAccessible ? 15 : 13),
                  ),
                )).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedClinic = clinics.firstWhere((c) => c.id == v);
                    _selectedDate = null;
                    _selectedTime = null;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Date picker
              Text(l10n.selectDate, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 13)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectedClinic != null ? _pickDate : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? localizeDate(_selectedDate!, settings.language)
                            : l10n.selectDate,
                        style: TextStyle(fontSize: isAccessible ? 15 : 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time slots
              if (_selectedDate != null) ...[
                Text(l10n.selectTime, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isAccessible ? 15 : 13)),
                const SizedBox(height: 8),
                if (slots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.noResults,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, i) {
                      final slot = slots[i];
                      final isSelected = _selectedTime == slot.time;
                      final isFull = slot.status == SlotStatus.full;
                      Color bgColor;
                      Color textColor;
                      if (isFull) {
                        bgColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.08);
                        textColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);
                      } else if (slot.status == SlotStatus.limited) {
                        bgColor = isSelected ? AppColors.gold : AppColors.gold.withOpacity(0.1);
                        textColor = isSelected ? Colors.white : AppColors.gold;
                      } else {
                        bgColor = isSelected ? AppColors.datePalmGreen : AppColors.datePalmGreen.withOpacity(0.1);
                        textColor = isSelected ? Colors.white : AppColors.datePalmGreen;
                      }

                      return Material(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: isFull ? null : () => setState(() => _selectedTime = slot.time),
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localizeTime(slot.time, settings.language),
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isAccessible ? 13 : 11,
                                ),
                              ),
                              Text(
                                isFull ? l10n.full : l10n.remaining(slot.remaining),
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: isAccessible ? 10 : 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedTime != null ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.datePalmGreen,
                      ),
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
