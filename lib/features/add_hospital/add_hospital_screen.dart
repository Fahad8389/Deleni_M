import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/generated_floor_plan.dart';
import '../../data/services/floor_plan_api_service.dart';
import '../../providers/generated_hospital_provider.dart';
import '../../providers/settings_provider.dart';

class _FloorEntry {
  String name;
  String? imageBase64;
  String? imageName;

  _FloorEntry({required this.name, this.imageBase64, this.imageName});
}

class AddHospitalScreen extends ConsumerStatefulWidget {
  const AddHospitalScreen({super.key});

  @override
  ConsumerState<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends ConsumerState<AddHospitalScreen> {
  final _nameController = TextEditingController();
  final _floors = <_FloorEntry>[];
  bool _isGenerating = false;
  String _progressText = '';
  String? _errorText;

  final _defaultFloorNames = [
    'Ground Floor',
    'First Floor',
    'Second Floor',
    'Third Floor',
    'Fourth Floor',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int floorIndex) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);

    setState(() {
      _floors[floorIndex].imageBase64 = base64;
      _floors[floorIndex].imageName = file.name;
    });
  }

  void _addFloor() {
    setState(() {
      final index = _floors.length;
      final name = index < _defaultFloorNames.length
          ? _defaultFloorNames[index]
          : 'Floor ${index + 1}';
      _floors.add(_FloorEntry(name: name));
    });
  }

  void _removeFloor(int index) {
    setState(() {
      _floors.removeAt(index);
    });
  }

  Future<void> _generate() async {
    final hospitalName = _nameController.text.trim();
    if (hospitalName.isEmpty) {
      setState(() => _errorText = 'Please enter a hospital name');
      return;
    }

    final floorsWithImages = _floors.where((f) => f.imageBase64 != null).toList();
    if (floorsWithImages.isEmpty) {
      setState(() => _errorText = 'Please upload at least one floor plan image');
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorText = null;
      _progressText = '';
    });

    try {
      final apiService = ref.read(floorPlanApiServiceProvider);
      final generatedFloors = <GeneratedFloorData>[];

      for (var i = 0; i < _floors.length; i++) {
        final floor = _floors[i];
        if (floor.imageBase64 == null) continue;

        setState(() {
          _progressText = 'Analyzing ${floor.name} (${i + 1}/${_floors.length})';
        });

        final floorPlan = await apiService.analyzeFloorPlan(
          imageBase64: floor.imageBase64!,
          hospitalName: hospitalName,
          floorName: floor.name,
          floorIndex: i,
          totalFloors: _floors.length,
        );

        generatedFloors.add(GeneratedFloorData(
          id: i,
          nameEn: floor.name,
          nameAr: floor.name, // Claude generates Arabic in the rooms
          floorPlan: floorPlan,
        ));
      }

      final hospitalId = 'gen-${const Uuid().v4().substring(0, 8)}';
      final hospital = GeneratedHospital(
        id: hospitalId,
        nameEn: hospitalName,
        nameAr: hospitalName,
        addressEn: 'Saudi Arabia',
        addressAr: 'المملكة العربية السعودية',
        floors: generatedFloors,
      );

      await ref.read(generatedHospitalsProvider.notifier).addHospital(hospital);
      ref.read(settingsProvider.notifier).setDefaultHospitalId(hospitalId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations(
                    ref.read(settingsProvider).language)
                .generationSuccess),
            backgroundColor: AppColors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorText = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations(settings.language);
    final isDark = settings.darkMode;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.go('/'),
        ),
        title: Text(l10n.addHospital,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: _isGenerating ? _buildLoadingState(l10n, textColor, subtitleColor)
          : _buildForm(l10n, isDark, surfaceColor, textColor, subtitleColor, borderColor),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.blue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.analyzingFloorPlans,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_progressText,
              style: TextStyle(color: subtitleColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, bool isDark, Color surfaceColor,
      Color textColor, Color subtitleColor, Color borderColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital name
          Text(l10n.hospitalName,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: l10n.hospitalNameHint,
                hintStyle: TextStyle(color: subtitleColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Floors section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Floors (${_floors.length})',
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _addFloor,
                icon: const Icon(Icons.add, size: 18, color: AppColors.blue),
                label: Text(l10n.addFloor,
                    style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_floors.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: subtitleColor),
                  const SizedBox(height: 8),
                  Text(l10n.tapToUpload,
                      style: TextStyle(color: subtitleColor, fontSize: 14)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      _addFloor();
                      _pickImage(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(l10n.addFloor),
                  ),
                ],
              ),
            ),

          ...List.generate(_floors.length, (index) {
            final floor = _floors[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  // Image thumbnail or upload button
                  GestureDetector(
                    onTap: () => _pickImage(index),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor),
                      ),
                      child: floor.imageBase64 != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                base64Decode(floor.imageBase64!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.add_photo_alternate, color: subtitleColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Floor name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 32,
                          child: TextField(
                            controller: TextEditingController(text: floor.name),
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) => floor.name = v,
                          ),
                        ),
                        Text(
                          floor.imageBase64 != null
                              ? (floor.imageName ?? 'Image uploaded')
                              : l10n.tapToUpload,
                          style: TextStyle(color: subtitleColor, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: () => _removeFloor(index),
                    icon: Icon(Icons.close, color: subtitleColor, size: 20),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Error message
          if (_errorText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE2DD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEB5757), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorText!,
                        style: const TextStyle(color: Color(0xFF37352F), fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _floors.any((f) => f.imageBase64 != null) ? _generate : null,
              icon: const Icon(Icons.auto_awesome, size: 20),
              label: Text(l10n.generateMap,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.blue.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
