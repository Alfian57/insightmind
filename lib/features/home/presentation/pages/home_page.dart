import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../screening/presentation/providers/screening_flow_provider.dart';
import '../../../shell/main_shell.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: size.height * 0.25,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text(
              'InsightMind',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          AppStrings.welcomeBack,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.howAreYou,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Start Card
                _QuickStartCard(
                  onStartScreening: () {
                    // Reset screening state and navigate to screening tab
                    ref.read(screeningFlowProvider.notifier).reset();
                    ref.read(navigationIndexProvider.notifier).setIndex(1);
                  },
                ),
                const SizedBox(height: 20),

                // Quick Actions
                Text(
                  AppStrings.quickActions,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.history,
                        label: 'Riwayat',
                        color: AppColors.tertiary,
                        onTap: () {
                          Navigator.pushNamed(context, '/history');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.sensors,
                        label: 'Biometrik',
                        color: AppColors.secondary,
                        onTap: () {
                          Navigator.pushNamed(context, '/biometric');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.picture_as_pdf,
                        label: 'Laporan',
                        color: AppColors.error,
                        onTap: () {
                          Navigator.pushNamed(context, '/report');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tips Card
                _TipsCard(),
                const SizedBox(height: 24),

                // Info Cards
                _InfoCard(
                  icon: Icons.security,
                  title: 'Privasi Terjamin',
                  description:
                      'Semua data Anda tersimpan secara lokal di perangkat. '
                      'Tidak ada data yang dikirim ke server.',
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.psychology,
                  title: 'AI On-Device',
                  description:
                      'Analisis kesehatan mental dilakukan langsung di perangkat '
                      'Anda menggunakan teknologi AI terkini.',
                  color: AppColors.info,
                ),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final VoidCallback onStartScreening;

  const _QuickStartCard({required this.onStartScreening});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      gradientColors: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Mulai Screening',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Jawab beberapa pertanyaan singkat untuk mengetahui kondisi kesehatan mental Anda saat ini.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onStartScreening,
              icon: const Icon(Icons.play_arrow),
              label: const Text(AppStrings.startScreening),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      backgroundColor: AppColors.warning.withOpacity(0.1),
      borderColor: AppColors.warning.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.warningDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Tips Hari Ini',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.warningDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Luangkan waktu 5-10 menit untuk melakukan screening rutin. '
                  'Mengenali kondisi mental adalah langkah pertama menuju kesehatan yang lebih baik.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warningDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
