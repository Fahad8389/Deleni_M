import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generated_floor_plan.dart';

class FloorPlanApiService {
  // Update after deploying to Render
  static const _baseUrl = 'http://localhost:8080';

  Future<GeneratedFloorPlan> analyzeFloorPlan({
    required String imageBase64,
    required String hospitalName,
    required String floorName,
    required int floorIndex,
    required int totalFloors,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/analyze-floor-plan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image_base64': imageBase64,
        'hospital_name': hospitalName,
        'floor_name': floorName,
        'floor_index': floorIndex,
        'total_floors': totalFloors,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to analyze floor plan: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GeneratedFloorPlan.fromJson(json);
  }
}
