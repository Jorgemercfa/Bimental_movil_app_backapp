class Administrators {
  String id;
  String email;
  String password;
  String? fcmToken; // Nuevo campo opcional

  Administrators(this.id, this.email, this.password, [this.fcmToken]);

  // Agrega un método para crear desde Firestore
  factory Administrators.fromMap(Map<String, dynamic> data) {
    return Administrators(
      data['id'],
      data['email'],
      data['password'],
      data['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}
