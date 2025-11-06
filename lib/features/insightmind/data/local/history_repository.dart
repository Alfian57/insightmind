import 'package:hive/hive.dart';
import 'package:insightmind/features/insightmind/data/local/screening_record.dart';
import 'package:uuid/uuid.dart';

class HistoryRepository {
  static const String boxName = 'screening_records';

  Future<Box<ScreeningRecord>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScreeningRecord>(boxName);
    }

    return await Hive.openBox<ScreeningRecord>(boxName);
  }

  Future<void> addRecord({
    required int score,
    required String riskLevel,
    String? note,
  }) async {
    final box = await _openBox();
    final id = const Uuid().v4();
    final record = ScreeningRecord(
      id: id,
      timestamp: DateTime.now(),
      score: score,
      riskLevel: riskLevel,
      note: note,
    );
    await box.put(id, record);
  }

  Future<List<ScreeningRecord>> getAll() async {
    final box = await _openBox();
    final records = box.values.toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> deleteById(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
