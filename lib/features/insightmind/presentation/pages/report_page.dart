import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../domain/usecases/report_generator.dart';
import '../providers/ai_prediction_provider.dart';
import '../providers/history_providers.dart';

/// Provider untuk ReportGenerator
final reportGeneratorProvider = Provider<ReportGenerator>((ref) {
  return ReportGenerator();
});

/// Halaman untuk generate dan preview laporan PDF
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _nameController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prediction = ref.watch(aiPredictionProvider);
    final features = ref.watch(featureVectorProvider);
    final completeness = ref.watch(dataCompletenessProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan PDF'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Laporan Profesional',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generate laporan PDF yang dapat dibagikan kepada profesional kesehatan mental.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data yang Akan Dilaporkan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DataSummaryRow(
                      icon: Icons.psychology,
                      label: 'Tingkat Risiko',
                      value: prediction.riskLevel,
                      valueColor: _getRiskColor(prediction.riskLevel),
                    ),
                    _DataSummaryRow(
                      icon: Icons.score,
                      label: 'Skor Analisis',
                      value: prediction.score.toStringAsFixed(2),
                    ),
                    _DataSummaryRow(
                      icon: Icons.verified,
                      label: 'Confidence',
                      value: prediction.confidencePercentage,
                    ),
                    _DataSummaryRow(
                      icon: Icons.data_usage,
                      label: 'Kelengkapan Data',
                      value:
                          '${(completeness.completenessPercentage * 100).toStringAsFixed(0)}%',
                    ),
                    const Divider(),
                    _DataSummaryRow(
                      icon: Icons.quiz,
                      label: 'Skor Screening',
                      value: features.screeningScore.toStringAsFixed(1),
                      isDetail: true,
                    ),
                    _DataSummaryRow(
                      icon: Icons.speed,
                      label: 'Activity Variance',
                      value: features.activityVar.toStringAsFixed(6),
                      isDetail: true,
                    ),
                    _DataSummaryRow(
                      icon: Icons.favorite,
                      label: 'PPG Variance',
                      value: features.ppgVar.toStringAsFixed(6),
                      isDetail: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Laporan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Anda',
                        hintText: 'Masukkan nama untuk laporan',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Warnings
            if (!completeness.isComplete) ...[
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Belum Lengkap',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              completeness.statusDescription,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Generate Buttons
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : () => _previewReport(context),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.preview),
              label: Text(_isGenerating ? 'Generating...' : 'Preview Laporan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isGenerating ? null : () => _shareReport(context),
              icon: const Icon(Icons.share),
              label: const Text('Bagikan Laporan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isGenerating ? null : () => _printReport(context),
              icon: const Icon(Icons.print),
              label: const Text('Cetak Laporan'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return Colors.red;
      case 'Sedang':
        return Colors.orange;
      case 'Rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _previewReport(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama Anda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdf = await _generatePdf();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Preview Laporan')),
            body: PdfPreview(
              build: (format) => pdf.save(),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _shareReport(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama Anda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdf = await _generatePdf();
      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'laporan_kesehatan_mental_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _printReport(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama Anda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdf = await _generatePdf();

      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
        name: 'Laporan Kesehatan Mental - ${_nameController.text.trim()}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<dynamic> _generatePdf() async {
    final reportGenerator = ref.read(reportGeneratorProvider);
    final prediction = ref.read(aiPredictionProvider);
    final features = ref.read(featureVectorProvider);

    // Ambil history langsung dari repository untuk memastikan data tersedia
    final historyRepository = ref.read(historyRepositoryProvider);
    final historyList = await historyRepository.getAll();

    // Convert history to list of maps
    final historyData = <Map<String, dynamic>>[];
    for (final item in historyList) {
      historyData.add({
        'score': item.score,
        'riskLevel': item.riskLevel,
        'createdAt': item.timestamp,
      });
    }

    return await reportGenerator.generateReport(
      patientName: _nameController.text.trim(),
      currentPrediction: prediction,
      currentFeatures: features,
      historyData: historyData,
    );
  }
}

/// Widget untuk menampilkan row data summary
class _DataSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDetail;

  const _DataSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isDetail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: isDetail ? 16 : 20,
            color: isDetail ? Colors.grey : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDetail ? 12 : 14,
                color: isDetail ? Colors.grey[600] : null,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDetail ? 12 : 14,
              color: valueColor ?? (isDetail ? Colors.grey[600] : null),
            ),
          ),
        ],
      ),
    );
  }
}
