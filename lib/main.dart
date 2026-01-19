import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/biometric/presentation/pages/biometric_page.dart';
import 'features/history/presentation/pages/history_page.dart';
import 'features/insightmind/data/local/screening_record.dart';
import 'features/insightmind/presentation/pages/report_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/screening/presentation/pages/screening_flow_page.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScreeningRecordAdapter());
  await Hive.openBox<ScreeningRecord>(AppConstants.screeningRecordsBox);
  await Hive.openBox('app_settings');

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: InsightMindApp()));
}

class InsightMindApp extends ConsumerStatefulWidget {
  const InsightMindApp({super.key});

  @override
  ConsumerState<InsightMindApp> createState() => _InsightMindAppState();
}

class _InsightMindAppState extends ConsumerState<InsightMindApp> {
  bool _showOnboarding = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final box = await Hive.openBox('app_settings');
    final completed = box.get(AppConstants.onboardingKey, defaultValue: false);
    setState(() {
      _showOnboarding = !completed;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routes: {
        '/biometric': (_) => const BiometricPage(),
        '/history': (_) => const HistoryPage(),
        '/screening': (_) => const ScreeningFlowPage(),
        '/report': (_) => const ReportPage(),
      },
      home: _showOnboarding
          ? OnboardingPage(
              onComplete: () {
                setState(() {
                  _showOnboarding = false;
                });
              },
            )
          : const MainShell(),
    );
  }
}
