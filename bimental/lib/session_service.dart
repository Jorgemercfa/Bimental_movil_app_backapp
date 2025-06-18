import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static Future<void> saveUserSession({
    required String id,
    required String email,
    String? name,
    String? lastName,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
    await prefs.setString('user_email', email);
    if (name != null) await prefs.setString('user_name', name);
    if (lastName != null) await prefs.setString('user_lastName', lastName);

    print("Sesión guardada - ID: $id, Email: $email");
  }

  static Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String?> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_lastName');
    print("Sesión limpiada");
  }

  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null;
  }

  static isAdmin() {}
}
