import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/data/local/history_repository.dart';
import 'package:insightmind/features/insightmind/data/local/screening_record.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository();
});

/// Notifier untuk refresh history list
class HistoryRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() {
    state++;
  }
}

final historyRefreshProvider = NotifierProvider<HistoryRefreshNotifier, int>(
  HistoryRefreshNotifier.new,
);

final historyListProvider = FutureProvider<List<ScreeningRecord>>((ref) async {
  // Watch refresh trigger untuk re-fetch saat data berubah
  ref.watch(historyRefreshProvider);
  final repository = ref.watch(historyRepositoryProvider);
  return repository.getAll();
});

/// Helper function untuk refresh history dari mana saja
void refreshHistory(WidgetRef ref) {
  ref.read(historyRefreshProvider.notifier).refresh();
}

/// Helper untuk Ref (non-widget context)
void refreshHistoryFromRef(Ref ref) {
  ref.read(historyRefreshProvider.notifier).refresh();
}
