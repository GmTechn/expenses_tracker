class CardModel {
  final int? id;
  final String email;
  final String amount;
  final String cardnumber;
  final String expirydate;
  final String username;
  final int colorOne;
  final int colorTwo;
  final int isDefault; // ✅ colonne isDefault

  CardModel({
    this.id,
    required this.email,
    required this.amount,
    required this.cardnumber,
    required this.expirydate,
    required this.username,
    required this.colorOne,
    required this.colorTwo,
    this.isDefault = 0, // valeur par défaut = 0
  });

  // Convertit CardModel en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'amount': amount,
      'cardnumber': cardnumber,
      'expirydate': expirydate,
      'username': username,
      'colorOne': colorOne,
      'colorTwo': colorTwo,
      'isDefault': isDefault,
    };
  }

  // Crée un CardModel à partir d'un Map (SQLite)
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] is int
          ? map['id'] as int
          : int.tryParse(map['id'].toString()),
      email: map['email']?.toString() ?? '',
      amount: map['amount']?.toString() ?? '0',
      cardnumber: map['cardnumber']?.toString() ?? '',
      expirydate: map['expirydate']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      colorOne: map['colorOne'] is int
          ? map['colorOne']
          : int.tryParse(map['colorOne'].toString()) ?? 0,
      colorTwo: map['colorTwo'] is int
          ? map['colorTwo']
          : int.tryParse(map['colorTwo'].toString()) ?? 0,
      isDefault: map['isDefault'] is int
          ? map['isDefault']
          : int.tryParse(map['isDefault'].toString()) ?? 0,
    );
  }
}
