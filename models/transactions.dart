class TransactionModel {
  final int? id;
  final String email;
  final String place;
  final double amount;
  final DateTime date;
  final String? logoPath;

  TransactionModel({
    this.id,
    required this.email,
    required this.place,
    required this.amount,
    required this.date,
    this.logoPath,
  });

  // Convertit un objet en Map pour SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'email': email,
      'place': place,
      'amount': amount,
      'date': date.toIso8601String(),
      'logoPath': logoPath,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Crée un objet à partir d'une Map SQLite
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      email: map['email'],
      place: map['place'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      logoPath: map['logoPath'],
    );
  }

  // Pour copier/modifier facilement
  TransactionModel copyWith({
    int? id,
    String? email,
    String? place,
    double? amount,
    DateTime? date,
    String? logoPath,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      email: email ?? this.email,
      place: place ?? this.place,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
