import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:insightmind/features/insightmind/data/local/screening_record.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScreeningRecordAdapter());
  await Hive.openBox<ScreeningRecord>('screening_records');
  runApp(ProviderScope(child: App()));
}
