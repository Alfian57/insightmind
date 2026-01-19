import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_animations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/biometric_providers.dart';
import '../widgets/accelerometer_section.dart';
import '../widgets/ppg_section.dart';
import '../widgets/data_status_card.dart';

/// Halaman pengukuran biometrik dengan UI modern
class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final completeness = ref.watch(dataCompletenessProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with gradient
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? AppColors.darkPrimaryGradient
                        : AppColors.primaryGradient,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppFadeIn(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            AppStrings.biometricTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppFadeIn(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            AppStrings.biometricSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.directions_walk),
                      text: 'Aktivitas',
                    ),
                    Tab(
                      icon: Icon(Icons.favorite),
                      text: 'PPG',
                    ),
                  ],
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Accelerometer Tab
                _AccelerometerTab(),
                // PPG Tab
                _PPGTab(),
              ],
            ),
          ),
        ],
      ),
      // Bottom status bar
      bottomNavigationBar: _BottomStatusBar(completeness: completeness),
    );
  }
}

class _AccelerometerTab extends StatelessWidget {
  const _AccelerometerTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppSlideIn(
            delay: const Duration(milliseconds: 100),
            child: const AccelerometerSection(),
          ),
          const SizedBox(height: 16),
          AppSlideIn(
            delay: const Duration(milliseconds: 200),
            child: const DataStatusCard(),
          ),
        ],
      ),
    );
  }
}

class _PPGTab extends StatelessWidget {
  const _PPGTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppSlideIn(
            delay: const Duration(milliseconds: 100),
            child: const PPGSection(),
          ),
          const SizedBox(height: 16),
          AppSlideIn(
            delay: const Duration(milliseconds: 200),
            child: const DataStatusCard(),
          ),
        ],
      ),
    );
  }
}

class _BottomStatusBar extends ConsumerWidget {
  final DataCompleteness completeness;

  const _BottomStatusBar({required this.completeness});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: _ProgressItem(
                    label: 'Screening',
                    isComplete: completeness.hasScreeningData,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProgressItem(
                    label: 'Aktivitas',
                    isComplete: completeness.hasActivityData,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProgressItem(
                    label: 'PPG',
                    isComplete: completeness.hasPPGData,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: completeness.isComplete
                    ? () => _showAnalysisDialog(context, ref)
                    : null,
                icon: const Icon(Icons.analytics),
                label: const Text('Simpan & Analisis'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalysisDialog(BuildContext context, WidgetRef ref) {
    final prediction = ref.read(aiPredictionProvider);
    final breakdown = ref.read(scoreBreakdownProvider);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.analytics,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Hasil Analisis AI'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Score
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRiskColor(prediction.riskLevel).withOpacity(0.1),
                    border: Border.all(
                      color: _getRiskColor(prediction.riskLevel),
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${prediction.score.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(prediction.riskLevel),
                        ),
                      ),
                      Text(
                        prediction.riskLevel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getRiskColor(prediction.riskLevel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Score breakdown
              Text(
                'Rincian Skor:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _BreakdownItem(
                label: 'Screening',
                score: (breakdown['screeningContribution'] as double? ?? 0) * 100,
              ),
              _BreakdownItem(
                label: 'Aktivitas',
                score: (breakdown['activityContribution'] as double? ?? 0) * 100,
              ),
              _BreakdownItem(
                label: 'PPG',
                score: (breakdown['ppgContribution'] as double? ?? 0) * 100,
              ),
              const SizedBox(height: 16),
              // Interpretation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getInterpretation(prediction.riskLevel),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveToHistory(context, ref);
            },
            child: const Text('Simpan ke Riwayat'),
          ),
        ],
      ),
    );
  }

  void _saveToHistory(BuildContext context, WidgetRef ref) {
    // Save data logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan ke riwayat'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'rendah':
        return AppColors.riskLow;
      case 'sedang':
        return AppColors.riskMedium;
      case 'tinggi':
        return AppColors.riskHigh;
      default:
        return AppColors.riskMedium;
    }
  }

  String _getInterpretation(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'rendah':
        return 'Kondisi kesehatan mental Anda dalam keadaan baik. '
            'Terus jaga kesehatan dengan pola hidup sehat.';
      case 'sedang':
        return 'Ada beberapa indikator yang perlu diperhatikan. '
            'Pertimbangkan untuk berbicara dengan profesional kesehatan mental.';
      case 'tinggi':
        return 'Disarankan untuk segera berkonsultasi dengan '
            'profesional kesehatan mental untuk evaluasi lebih lanjut.';
      default:
        return 'Lakukan pengukuran lengkap untuk mendapatkan analisis.';
    }
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final bool isComplete;

  const _ProgressItem({
    required this.label,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete ? AppColors.success : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isComplete ? AppColors.success : theme.hintColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isComplete ? AppColors.success : theme.hintColor,
              fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem extends StatelessWidget {
  final String label;
  final double score;

  const _BreakdownItem({
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${score.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  Widget build(context, shrinkOffset, overlapsContent) => child;

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      child != oldDelegate.child;
}
