import 'package:hive_ce/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 0)
class Appointment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String hospitalId;

  @HiveField(2)
  final String destinationId;

  @HiveField(3)
  final String date; // yyyy-MM-dd

  @HiveField(4)
  final String time; // HH:mm

  Appointment({
    required this.id,
    required this.hospitalId,
    required this.destinationId,
    required this.date,
    required this.time,
  });
}
