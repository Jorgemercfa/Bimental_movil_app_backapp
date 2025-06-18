import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'User.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._internal();
  final Uuid _uuid = Uuid();

  factory UserRepository() {
    return instance;
  }

  UserRepository._internal();

  List<User> users = [];

  Future<String> addUser(User newUser) async {
    try {
      final userId = _generateUniqueId();
      final userData = {
        'id': userId,
        'name': newUser.name,
        'lastName': newUser.lastName,
        'email': newUser.email,
        'phone': newUser.phone,
        'password': newUser.password
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      print("Usuario registrado con ID: $userId");
      return userId;
    } catch (e) {
      print("Error al registrar usuario: $e");
      throw Exception("Error al registrar usuario: $e");
    }
  }

  String _generateUniqueId() {
    return _uuid.v4();
  }

  Future<List<User>> getUsers() async {
    List<User> usersRegistered = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").get();

      for (var doc in snapshot.docs) {
        final userInfo = doc.data() as Map<String, dynamic>;

        // Validación completa de campos
        final user = User(
          _validateField(userInfo['id']),
          _validateField(userInfo['name'], defaultValue: 'Desconocido'),
          _validateField(userInfo['lastName']),
          _validateField(userInfo['email']),
          _validateField(userInfo['password']),
          _validateField(userInfo['phone']),
        );

        print("Usuario recuperado: ${user.toString()}");
        usersRegistered.add(user);
      }
    } catch (e) {
      print("Error al obtener usuarios: $e");
      throw Exception("Error al obtener usuarios: $e");
    }
    return usersRegistered;
  }

  // Método auxiliar para validar campos
  String _validateField(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    try {
      if (email.isEmpty || newPassword.isEmpty) {
        throw Exception("Email y contraseña son requeridos");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      await querySnapshot.docs.first.reference
          .update({"password": newPassword});

      return true;
    } catch (e) {
      print("Error al actualizar contraseña: $e");
      return false;
    }
  }

  Future<bool> updateUserData(
      String email, String name, String lastName, String phone) async {
    try {
      if (email.isEmpty) throw Exception("Email es requerido");

      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      await querySnapshot.docs.first.reference
          .update({"name": name, "lastName": lastName, "phone": phone});

      return true;
    } catch (e) {
      print("Error al actualizar datos: $e");
      return false;
    }
  }
}
