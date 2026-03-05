import 'package:flutter/material.dart';
import '../../../data/models/generated_floor_plan.dart';
import 'generated_floor_plan_painter.dart';
import 'kf_ground.dart';
import 'kf_first.dart';
import 'kf_second.dart';
import 'rc_ground.dart';
import 'rc_first.dart';
import 'rc_second.dart';

/// Registry of AI-generated floor plans.
final Map<String, GeneratedFloorPlan> _generatedFloorPlans = {};

void registerGeneratedFloorPlan(String hospitalId, int floorId, GeneratedFloorPlan plan) {
  _generatedFloorPlans['${hospitalId}_$floorId'] = plan;
}

void clearGeneratedFloorPlans() {
  _generatedFloorPlans.clear();
}

CustomPainter getFloorPlanPainter({
  required String hospitalId,
  required int floorId,
  required bool darkMode,
  required String locale,
}) {
  final key = '${hospitalId}_$floorId';
  switch (key) {
    case 'king-faisal_0':
      return KFGroundFloorPainter(darkMode: darkMode, locale: locale);
    case 'king-faisal_1':
      return KFFirstFloorPainter(darkMode: darkMode, locale: locale);
    case 'king-faisal_2':
      return KFSecondFloorPainter(darkMode: darkMode, locale: locale);
    case 'riyadh-care_0':
      return RCGroundFloorPainter(darkMode: darkMode, locale: locale);
    case 'riyadh-care_1':
      return RCFirstFloorPainter(darkMode: darkMode, locale: locale);
    case 'riyadh-care_2':
      return RCSecondFloorPainter(darkMode: darkMode, locale: locale);
    default:
      // Check AI-generated floor plans
      final generated = _generatedFloorPlans[key];
      if (generated != null) {
        return GeneratedFloorPlanPainter(
          floorPlan: generated,
          darkMode: darkMode,
          locale: locale,
        );
      }
      return KFGroundFloorPainter(darkMode: darkMode, locale: locale);
  }
}
