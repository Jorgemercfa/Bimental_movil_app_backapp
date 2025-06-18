class User {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  User(
      this.id, this.name, this.lastName, this.email, this.password, this.phone);

  @override
  String toString() {
    return 'User{id: $id, name: $name, lastName: $lastName, email: $email, phone: $phone}';
  }
}
