import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../insightmind/data/local/screening_record.dart';

/// Repository for managing screening history
class HistoryRepository {
  Future<List<ScreeningRecord>> getAll() async {
    final box = await Hive.openBox<ScreeningRecord>(
      AppConstants.screeningRecordsBox,
    );
    final records = box.values.toList();
    // Sort by timestamp descending (newest first)
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  Future<void> addRecord({
    required int score,
    required String riskLevel,
  }) async {
    final box = await Hive.openBox<ScreeningRecord>(
      AppConstants.screeningRecordsBox,
    );
    final record = ScreeningRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      score: score,
      riskLevel: riskLevel,
      timestamp: DateTime.now(),
    );
    await box.add(record);
  }

  Future<void> deleteById(String id) async {
    final box = await Hive.openBox<ScreeningRecord>(
      AppConstants.screeningRecordsBox,
    );
    final index = box.values.toList().indexWhere((r) => r.id == id);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  Future<void> clearAll() async {
    final box = await Hive.openBox<ScreeningRecord>(
      AppConstants.screeningRecordsBox,
    );
    await box.clear();
  }
}

/// Provider for history repository
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// Provider for history list
final historyListProvider = FutureProvider<List<ScreeningRecord>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.getAll();
});
