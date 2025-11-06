import 'package:hive/hive.dart';

part 'screening_record.g.dart';

@HiveType(typeId: 1)
class ScreeningRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  int score;

  @HiveField(3)
  String riskLevel;

  @HiveField(4)
  String? note;

  ScreeningRecord({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.riskLevel,
    this.note,
  });
}
