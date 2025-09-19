class TransactionModel {
  final int? id;
  final String email;
  final String place;
  final double amount;
  final DateTime date;
  final String? logoPath;
  final int? cardId; // ✅ ajouté

  TransactionModel({
    this.id,
    required this.email,
    required this.place,
    required this.amount,
    required this.date,
    this.logoPath,
    this.cardId, // ✅ ajouté
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'email': email,
      'place': place,
      'amount': amount,
      'date': date.toIso8601String(),
      'logoPath': logoPath,
      'cardId': cardId, // ✅ ajouté
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      email: map['email'],
      place: map['place'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      logoPath: map['logoPath'],
      cardId: map['cardId'], // ✅ ajouté
    );
  }

  TransactionModel copyWith({
    int? id,
    String? email,
    String? place,
    double? amount,
    DateTime? date,
    String? logoPath,
    int? cardId, // ✅ ajouté
  }) {
    return TransactionModel(
      id: id ?? this.id,
      email: email ?? this.email,
      place: place ?? this.place,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      logoPath: logoPath ?? this.logoPath,
      cardId: cardId ?? this.cardId, // ✅ ajouté
    );
  }
}
