enum Payer { poom, poy }

class Entry {
  final String id;
  final double amount;
  final double percentage;
  final Payer payer;
  final DateTime timestamp;

  Entry({
    required this.id,
    required this.amount,
    required this.percentage,
    required this.payer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'percentage': percentage,
      'payer': payer.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      amount: json['amount'],
      percentage: json['percentage'],
      payer: Payer.values[json['payer']],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
