enum PocketStatus {
  owed,
  paid,
  owedToYou,
}

class Pocket {
  final String title;
  final int participants;
  final double progress; // 0.0 to 1.0
  final PocketStatus status;
  final double amount;
  final bool isRecurring;
  final String? recurringPeriod;

  Pocket({
    required this.title,
    required this.participants,
    required this.progress,
    required this.status,
    required this.amount,
    this.isRecurring = false,
    this.recurringPeriod,
  });
}
