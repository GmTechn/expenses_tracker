class User {
  final int? id;
  final String fname;
  final String lname;
  final String email;
  final String password;
  final String phone;
  final String photoPath;

  User({
    this.id,
    required this.fname,
    required this.lname,
    required this.email,
    required this.password,
    this.phone = '',
    this.photoPath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fname': fname,
      'lname': lname,
      'email': email,
      'password': password,
      'phone': phone,
      'photoPath': photoPath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fname: map['fname'],
      lname: map['lname'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      photoPath: map['photoPath'],
    );
  }
}
