import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../insightmind/domain/usecases/calculate_risk_level.dart';
import '../providers/screening_flow_provider.dart';

class ScreeningResultPage extends ConsumerStatefulWidget {
  const ScreeningResultPage({super.key});

  @override
  ConsumerState<ScreeningResultPage> createState() =>
      _ScreeningResultPageState();
}

class _ScreeningResultPageState extends ConsumerState<ScreeningResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saved) {
      _saveResult();
    }
  }

  Future<void> _saveResult() async {
    final state = ref.read(screeningFlowProvider);
    final calculateRisk = CalculateRiskLevel();
    final result = calculateRisk.execute(state.totalScore);

    try {
      await ref.read(historyRepositoryProvider).addRecord(
            score: result.score,
            riskLevel: result.riskLevel,
          );
      ref.invalidate(historyListProvider);
      _saved = true;
    } catch (e) {
      // Handle error silently or show message
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(screeningFlowProvider);
    final calculateRisk = CalculateRiskLevel();
    final result = calculateRisk.execute(state.totalScore);

    final riskColor = _getRiskColor(result.riskLevel);
    final recommendation = _getRecommendation(result.riskLevel);
    final tips = _getTips(result.riskLevel);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Result Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          riskColor.withOpacity(0.2),
                          riskColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: riskColor,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _getRiskIcon(result.riskLevel),
                          size: 40,
                          color: riskColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Score
                Text(
                  'Skor Anda',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.score}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Risk Badge
                AppRiskBadge(
                  riskLevel: result.riskLevel,
                  large: true,
                ),
                const SizedBox(height: 32),

                // Recommendation Card
                AppCard(
                  backgroundColor: riskColor.withOpacity(0.05),
                  borderColor: riskColor.withOpacity(0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: riskColor),
                          const SizedBox(width: 8),
                          Text(
                            'Rekomendasi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recommendation,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tips Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips untuk Anda',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Saved indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hasil telah disimpan di riwayat',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.successDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                AppButton(
                  text: 'Kembali ke Beranda',
                  icon: Icons.home,
                  useGradient: true,
                  onPressed: () {
                    ref.read(screeningFlowProvider.notifier).reset();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 12),
                AppOutlinedButton(
                  text: 'Screening Ulang',
                  icon: Icons.refresh,
                  onPressed: () {
                    ref.read(screeningFlowProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return AppColors.success;
      case 'Sedang':
        return AppColors.warning;
      case 'Tinggi':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return Icons.sentiment_very_satisfied;
      case 'Sedang':
        return Icons.sentiment_neutral;
      case 'Tinggi':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.psychology;
    }
  }

  String _getRecommendation(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return 'Hasil screening menunjukkan Anda mungkin mengalami tekanan yang cukup berat. '
            'Sangat disarankan untuk berkonsultasi dengan profesional kesehatan mental '
            'seperti psikolog atau konselor. Jangan ragu untuk mencari bantuan.';
      case 'Sedang':
        return 'Hasil screening menunjukkan beberapa tanda yang perlu diperhatikan. '
            'Pertimbangkan untuk melakukan aktivitas relaksasi, berbicara dengan orang terdekat, '
            'dan memantau kondisi Anda secara berkala.';
      default:
        return 'Hasil screening menunjukkan kondisi yang baik. Pertahankan gaya hidup sehat, '
            'jaga keseimbangan antara kerja dan istirahat, serta tetap terhubung dengan '
            'orang-orang terdekat Anda.';
    }
  }

  List<String> _getTips(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return [
          'Hubungi profesional kesehatan mental sesegera mungkin',
          'Ceritakan perasaan Anda kepada orang yang dipercaya',
          'Hindari mengonsumsi alkohol atau zat berbahaya',
          'Jika memiliki pikiran menyakiti diri sendiri, segera hubungi hotline krisis',
        ];
      case 'Sedang':
        return [
          'Lakukan teknik pernapasan dalam saat merasa cemas',
          'Olahraga ringan 30 menit setiap hari',
          'Batasi konsumsi kafein dan layar sebelum tidur',
          'Pertimbangkan untuk berbicara dengan konselor',
        ];
      default:
        return [
          'Pertahankan pola tidur yang teratur (7-8 jam)',
          'Lanjutkan aktivitas yang Anda nikmati',
          'Jaga hubungan sosial dengan orang terdekat',
          'Lakukan screening berkala untuk memantau kondisi',
        ];
    }
  }
}
