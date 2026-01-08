import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../entities/feature_vector.dart';
import '../entities/prediction_result.dart';

/// ReportGenerator - Use Case untuk menghasilkan laporan PDF on-device
///
/// Laporan berisi rekap perkembangan kondisi mental yang layak
/// dibagikan kepada profesional kesehatan mental.
class ReportGenerator {
  /// Generate PDF report dari data kesehatan mental
  ///
  /// [patientName] - Nama pasien/pengguna
  /// [currentPrediction] - Hasil prediksi terkini
  /// [currentFeatures] - FeatureVector terkini
  /// [historyData] - List riwayat screening (Map dengan keys: score, riskLevel, createdAt)
  ///
  /// Returns [pw.Document] yang siap di-print atau di-share
  Future<pw.Document> generateReport({
    required String patientName,
    required PredictionResult currentPrediction,
    required FeatureVector currentFeatures,
    required List<Map<String, dynamic>> historyData,
  }) async {
    final pdf = pw.Document(
      title: 'Laporan Kesehatan Mental - $patientName',
      author: 'InsightMind App',
      creator: 'InsightMind - AI-Powered Mental Health Tracker',
    );

    // Gunakan format tanggal yang aman tanpa locale spesifik
    final dateFormat = DateFormat('d MMMM yyyy');
    final dateTimeFormat = DateFormat('d MMM yyyy, HH:mm');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) =>
            _buildHeader(context, patientName, now, dateFormat),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Disclaimer
          _buildDisclaimer(),
          pw.SizedBox(height: 20),

          // Ringkasan Kondisi Terkini
          _buildCurrentConditionSection(
            currentPrediction,
            currentFeatures,
            dateTimeFormat,
          ),
          pw.SizedBox(height: 20),

          // Detail Analisis AI
          _buildAIAnalysisSection(currentPrediction, currentFeatures),
          pw.SizedBox(height: 20),

          // Riwayat Perkembangan
          _buildHistorySection(historyData, dateTimeFormat),
          pw.SizedBox(height: 20),

          // Statistik Ringkasan
          if (historyData.isNotEmpty) ...[
            _buildStatisticsSection(historyData),
            pw.SizedBox(height: 20),
          ],

          // Rekomendasi
          _buildRecommendationsSection(currentPrediction.riskLevel),
          pw.SizedBox(height: 20),

          // Catatan untuk Profesional
          _buildProfessionalNotesSection(),
        ],
      ),
    );

    return pdf;
  }

  /// Header laporan
  pw.Widget _buildHeader(
    pw.Context context,
    String patientName,
    DateTime date,
    DateFormat dateFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'InsightMind',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Laporan Kesehatan Mental',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                patientName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                dateFormat.format(date),
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Footer laporan
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dibuat oleh InsightMind App',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// Disclaimer
  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.amber200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '⚠️ DISCLAIMER',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.amber900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Laporan ini dihasilkan oleh aplikasi InsightMind menggunakan AI on-device '
            'dan BUKAN merupakan diagnosis medis. Hasil analisis bersifat indikatif dan '
            'harus dikonsultasikan dengan profesional kesehatan mental yang berkualifikasi '
            'untuk diagnosis dan penanganan yang tepat.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.amber800),
          ),
        ],
      ),
    );
  }

  /// Section kondisi terkini
  pw.Widget _buildCurrentConditionSection(
    PredictionResult prediction,
    FeatureVector features,
    DateFormat dateFormat,
  ) {
    final riskColor = _getRiskColor(prediction.riskLevel);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'KONDISI TERKINI',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Tingkat Risiko',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      prediction.riskLevel,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Skor Analisis',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      prediction.score.toStringAsFixed(2),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Tingkat Keyakinan',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      prediction.confidencePercentage,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Waktu Analisis: ${dateFormat.format(prediction.timestamp)}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// Section analisis AI
  pw.Widget _buildAIAnalysisSection(
    PredictionResult prediction,
    FeatureVector features,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DETAIL ANALISIS AI',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Komponen yang Dianalisis:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildAnalysisRow(
            'Skor Screening (Kuesioner)',
            features.screeningScore.toStringAsFixed(1),
            'Bobot: 60%',
          ),
          _buildAnalysisRow(
            'Variabilitas Aktivitas (Accelerometer)',
            features.activityVar.toStringAsFixed(6),
            'Bobot: 20%',
          ),
          _buildAnalysisRow(
            'Variabilitas PPG (Kamera)',
            features.ppgVar.toStringAsFixed(6),
            'Bobot: 20%',
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Formula Prediksi:',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Score = (0.6 × Screening) + (0.2 × ActivityVar × 10) + (0.2 × PPGVar × 1000)',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAnalysisRow(String label, String value, String weight) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              weight,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ),
        ],
      ),
    );
  }

  /// Section riwayat
  pw.Widget _buildHistorySection(
    List<Map<String, dynamic>> historyData,
    DateFormat dateFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RIWAYAT PERKEMBANGAN',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          if (historyData.isEmpty)
            pw.Text(
              'Belum ada riwayat screening tersedia.',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('No', isHeader: true),
                    _tableCell('Tanggal', isHeader: true),
                    _tableCell('Skor', isHeader: true),
                    _tableCell('Risiko', isHeader: true),
                  ],
                ),
                // Data rows (max 10)
                ...historyData.take(10).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final date = item['createdAt'] as DateTime?;
                  final score = (item['score'] as num?)?.toDouble() ?? 0.0;
                  final riskLevel = item['riskLevel'] as String? ?? 'N/A';

                  return pw.TableRow(
                    children: [
                      _tableCell('${index + 1}'),
                      _tableCell(
                        date != null ? dateFormat.format(date) : 'N/A',
                      ),
                      _tableCell(score.toStringAsFixed(1)),
                      _tableCell(riskLevel),
                    ],
                  );
                }),
              ],
            ),
          if (historyData.length > 10)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Text(
                '* Menampilkan 10 dari ${historyData.length} riwayat terbaru',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Section statistik
  pw.Widget _buildStatisticsSection(List<Map<String, dynamic>> historyData) {
    final scores = historyData
        .map((h) => (h['score'] as num?)?.toDouble() ?? 0.0)
        .toList();

    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    int lowCount = 0, medCount = 0, highCount = 0;
    for (final score in scores) {
      if (score > 25) {
        highCount++;
      } else if (score >= 12) {
        medCount++;
      } else {
        lowCount++;
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.blue50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'STATISTIK RINGKASAN',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _statBox('Total Screening', '${historyData.length}'),
              _statBox('Rata-rata Skor', avgScore.toStringAsFixed(1)),
              _statBox('Skor Terendah', minScore.toStringAsFixed(1)),
              _statBox('Skor Tertinggi', maxScore.toStringAsFixed(1)),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Distribusi Tingkat Risiko:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Text(
                'Rendah: $lowCount',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.green),
              ),
              pw.SizedBox(width: 16),
              pw.Text(
                'Sedang: $medCount',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange),
              ),
              pw.SizedBox(width: 16),
              pw.Text(
                'Tinggi: $highCount',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _statBox(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Section rekomendasi
  pw.Widget _buildRecommendationsSection(String riskLevel) {
    final recommendations = _getRecommendations(riskLevel);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'REKOMENDASI',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          ...recommendations.map(
            (rec) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Expanded(
                    child: pw.Text(
                      rec,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getRecommendations(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return [
          'Segera konsultasikan dengan profesional kesehatan mental (psikolog/psikiater).',
          'Jangan ragu untuk menghubungi hotline kesehatan mental jika diperlukan.',
          'Libatkan orang terdekat untuk mendampingi proses pemulihan.',
          'Hindari isolasi diri dan tetap terhubung dengan sistem pendukung.',
          'Pertimbangkan untuk mengambil cuti jika diperlukan.',
        ];
      case 'Sedang':
        return [
          'Pertimbangkan untuk berkonsultasi dengan konselor atau psikolog.',
          'Praktikkan teknik relaksasi seperti meditasi atau pernapasan dalam.',
          'Jaga pola tidur yang teratur (7-9 jam per malam).',
          'Lakukan aktivitas fisik ringan secara rutin (minimal 30 menit/hari).',
          'Batasi konsumsi kafein dan alkohol.',
          'Luangkan waktu untuk hobi dan aktivitas yang menyenangkan.',
        ];
      case 'Rendah':
        return [
          'Pertahankan gaya hidup sehat yang sudah berjalan.',
          'Lanjutkan aktivitas fisik dan sosial secara rutin.',
          'Tetap waspada terhadap perubahan mood yang signifikan.',
          'Praktikkan self-care secara konsisten.',
          'Lakukan screening berkala untuk memantau kondisi.',
        ];
      default:
        return [
          'Lakukan screening untuk mendapatkan analisis kondisi mental.',
          'Jaga kesehatan fisik dan mental dengan gaya hidup seimbang.',
        ];
    }
  }

  /// Section catatan untuk profesional
  pw.Widget _buildProfessionalNotesSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CATATAN UNTUK PROFESIONAL',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Laporan ini dihasilkan oleh aplikasi InsightMind yang menggunakan '
            'pendekatan rule-based AI untuk analisis awal kondisi kesehatan mental. '
            'Data dikumpulkan dari:',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '1. Kuesioner self-report berbasis PHQ/DASS (9 pertanyaan)\n'
            '2. Data accelerometer untuk mengukur pola aktivitas/kegelisahan\n'
            '3. Data PPG (photoplethysmography) via kamera untuk estimasi variabilitas detak jantung',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Data ini dapat digunakan sebagai informasi pendukung untuk asesmen '
            'klinis lebih lanjut. Silakan validasi dengan instrumen standar dan '
            'wawancara klinis yang sesuai.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  /// Helper untuk mendapatkan warna risiko
  PdfColor _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return PdfColors.red;
      case 'Sedang':
        return PdfColors.orange;
      case 'Rendah':
        return PdfColors.green;
      default:
        return PdfColors.grey;
    }
  }
}
