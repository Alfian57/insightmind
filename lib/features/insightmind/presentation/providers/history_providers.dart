import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/data/local/history_repository.dart';
import 'package:insightmind/features/insightmind/data/local/screening_record.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

final historyListProvider = FutureProvider<List<ScreeningRecord>>((ref) async {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.getAll();
});
