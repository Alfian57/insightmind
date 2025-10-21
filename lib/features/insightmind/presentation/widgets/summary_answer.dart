class SummaryAnswer {
  final int number;
  final String question;
  final String answer;
  final bool flagged;

  const SummaryAnswer({
    required this.number,
    required this.question,
    required this.answer,
    this.flagged = false,
  });
}
