# Riverpod Provider Documentation

## Overview

File ini berisi provider yang dibuat menggunakan Riverpod untuk mengelola state aplikasi InsightMind, khususnya untuk fitur kuisioner mental health assessment.

## Providers yang Tersedia

### 1. `calculateRiskLevelProvider`

**Type**: `Provider<CalculateRiskLevel>`
**Description**: Menyediakan use case untuk menghitung tingkat risiko berdasarkan skor.

```dart
// Cara menggunakan:
final calculateRiskLevel = ref.watch(calculateRiskLevelProvider);
final result = calculateRiskLevel.execute(score);
```

### 2. `questionsProvider`

**Type**: `Provider<List<Question>>`
**Description**: Menyediakan daftar pertanyaan kuisioner.

```dart
// Cara menggunakan:
final questions = ref.watch(questionsProvider);
```

### 3. `questionnaireProvider`

**Type**: `StateNotifierProvider<QuestionnaireNotifier, QuestionnaireState>`
**Description**: Provider utama untuk mengelola state kuisioner.

**Methods pada QuestionnaireNotifier:**

- `answerQuestion(String questionId, int score)` - Menyimpan jawaban
- `completeQuestionnaire()` - Menyelesaikan kuisioner
- `resetQuestionnaire()` - Reset kuisioner
- `getAnswer(String questionId)` - Mendapatkan jawaban untuk pertanyaan tertentu

```dart
// Cara menggunakan:
final questionnaireState = ref.watch(questionnaireProvider);
final notifier = ref.read(questionnaireProvider.notifier);

// Menjawab pertanyaan
notifier.answerQuestion('q1', 2);

// Menyelesaikan kuisioner
notifier.completeQuestionnaire();
```

### 4. `mentalResultProvider`

**Type**: `Provider<MentalResult?>`
**Description**: Menyediakan hasil assessment mental health. Return `null` jika kuisioner belum selesai.

```dart
// Cara menggunakan:
final result = ref.watch(mentalResultProvider);
if (result != null) {
  print('Skor: ${result.score}, Risk Level: ${result.riskLevel}');
}
```

### 5. `questionnaireProgressProvider`

**Type**: `Provider<double>`
**Description**: Menyediakan progress kuisioner (0.0 - 1.0).

```dart
// Cara menggunakan:
final progress = ref.watch(questionnaireProgressProvider);
final percentage = (progress * 100).toInt();
```

### 6. `canCompleteQuestionnaireProvider`

**Type**: `Provider<bool>`
**Description**: Mengecek apakah kuisioner dapat diselesaikan.

```dart
// Cara menggunakan:
final canComplete = ref.watch(canCompleteQuestionnaireProvider);
```

### 7. `unansweredQuestionsProvider`

**Type**: `Provider<List<Question>>`
**Description**: Menyediakan daftar pertanyaan yang belum dijawab.

```dart
// Cara menggunakan:
final unansweredQuestions = ref.watch(unansweredQuestionsProvider);
```

### 8. `answerStatsProvider`

**Type**: `Provider<Map<String, dynamic>>`
**Description**: Menyediakan statistik jawaban untuk analytics.

```dart
// Cara menggunakan:
final stats = ref.watch(answerStatsProvider);
print('Average Score: ${stats['averageScore']}');
```

## QuestionnaireState Properties

### `answers`

**Type**: `Map<String, int>`
**Description**: Menyimpan mapping question ID ke score jawaban.

### `isCompleted`

**Type**: `bool`
**Description**: Status apakah kuisioner sudah diselesaikan.

### `totalScore`

**Type**: `int` (getter)
**Description**: Total skor dari semua jawaban.

### `isAllAnswered`

**Type**: `bool` (getter)
**Description**: Mengecek apakah semua pertanyaan sudah dijawab.

## Contoh Penggunaan Lengkap

### Di Widget

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final questionnaireState = ref.watch(questionnaireProvider);
    final progress = ref.watch(questionnaireProgressProvider);

    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            return ListTile(
              title: Text(question.text),
              onTap: () {
                // Menjawab dengan skor 2
                ref.read(questionnaireProvider.notifier)
                   .answerQuestion(question.id, 2);
              },
            );
          },
        ),
      ],
    );
  }
}
```

### Menggunakan Listener untuk Side Effects

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(mentalResultProvider, (previous, next) {
      if (next != null) {
        // Kuisioner selesai, tampilkan hasil
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hasil Assessment'),
            content: Text('Skor: ${next.score}, Risk: ${next.riskLevel}'),
          ),
        );
      }
    });

    return YourWidgetHere();
  }
}
```

## Tips Penggunaan

1. **Selalu gunakan `ref.watch()`** untuk mendengarkan perubahan state
2. **Gunakan `ref.read()`** untuk mengakses notifier atau melakukan action
3. **Gunakan `ref.listen()`** untuk side effects seperti navigasi atau menampilkan dialog
4. **Provider akan otomatis dispose** saat widget tidak digunakan lagi
5. **State akan tetap ada** selama provider masih di-watch oleh widget mana pun

## Error Handling

Provider ini sudah menangani beberapa edge case:

- Mengembalikan `null` pada `mentalResultProvider` jika kuisioner belum selesai
- Melindungi dari pembagian dengan nol pada progress calculation
- Validasi bahwa semua pertanyaan sudah dijawab sebelum completion

## Testing

Untuk testing, Anda dapat menggunakan `ProviderContainer`:

```dart
test('questionnaire provider test', () {
  final container = ProviderContainer();

  // Test initial state
  expect(container.read(questionnaireProvider).answers, isEmpty);

  // Test answering question
  container.read(questionnaireProvider.notifier).answerQuestion('q1', 2);
  expect(container.read(questionnaireProvider).answers['q1'], 2);

  container.dispose();
});
```
