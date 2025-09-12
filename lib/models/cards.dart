class CardModel {
  final int? id;
  final String email;
  final String amount;
  final String cardnumber;
  final String expirydate;
  final String username;
  final int colorOne;
  final int colorTwo;

  CardModel({
    this.id,
    required this.email,
    required this.amount,
    required this.cardnumber,
    required this.expirydate,
    required this.username,
    required this.colorOne,
    required this.colorTwo,
  });

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
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int?,
      email: map['email'],
      amount: map['amount'],
      cardnumber: map['cardnumber'],
      expirydate: map['expirydate'],
      username: map['username'],
      colorOne: map['colorOne'],
      colorTwo: map['colorTwo'],
    );
  }
}
