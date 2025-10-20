import 'package:flutter/material.dart';
import 'package:insightmind/features/insightmind/presentation/pages/provider_demo_page.dart';
// import 'package:insightmind/features/insightmind/presentation/pages/home_page.dart';
// import 'package:insightmind/features/insightmind/presentation/pages/summary_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const ProviderDemoPage(), // Gunakan demo page untuk test provider
    );
  }
}
