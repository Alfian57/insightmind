class AnswerOption {
  final String label;  // contoh: "Tidak Pernah", "Beberapa Hari", ...
  final int score;     // 0..3

  const AnswerOption({required this.label, required this.score});
}

class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;

  const Question({
    required this.id,
    required this.text,
    required this.options,
  });
}

/// Contoh 9 pertanyaan gaya PHQ/DASS (parafrase; bukan kutipan verbatim)
const defaultQuestions = <Question>[
  Question(
    id: 'q1',
    text: 'Dalam 2 minggu terakhir, seberapa sering Anda merasa sedih atau murung?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'q2',
    text: 'Kesulitan menikmati hal-hal yang biasanya menyenangkan?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  // ... tambahkan q3..q9 dengan pola sama (9 total)
  Question(
    id: 'q9',
    text: 'Merasa sangat lelah/kurang energi dalam aktivitas sehari-hari?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
];