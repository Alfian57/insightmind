import 'package:flutter/material.dart';
import 'features/insightmind/presentation/pages/home_page.dart';

class InsightMindApp extends StatelessWidget {
  const InsightMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightMind',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), // halaman yang akan dibuat atau disimulasikan
    );
  }
}
