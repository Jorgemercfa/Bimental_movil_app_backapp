import 'package:bimental/CofigurationUser.dart';
import 'package:bimental/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bimental/RegisterUserPage.dart';
import 'ForgetPassword.dart';
import 'Home.dart';
import 'SignInAdm.dart';

// Lista en memoria para almacenar los usuarios registrados
List<Map<String, String>> usuariosRegistrados = [];

// Notificador global para manejar el tema oscuro
ValueNotifier<bool> isDarkModeEnabled = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialización de Firebase
  await Firebase.initializeApp(
    // Si tienes firebase_options.dart, utiliza la opción de abajo:
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeEnabled,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'BiMental',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: isDark
                ? const Color.fromARGB(255, 0, 0, 0)
                : Colors.white, // Se actualiza dinámicamente
            textTheme: TextTheme(
              bodyLarge:
              TextStyle(color: isDark ? Colors.white : Color(0xFF1A119B)),
              bodyMedium:
              TextStyle(color: isDark ? Colors.white : Color(0xFF1A119B)),
              bodySmall:
              TextStyle(color: isDark ? Colors.white : Color(0xFF1A119B)),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/Home': (context) => HomePage(),
            '/ForgetPassword': (context) => ResetPasswordPage(),
            '/RegisterUserPage': (context) => RegisterUserPage(),
            '/SignInAdmin': (context) => SignInAdmin(),
            '/ConfigurationUser': (context) => ConfiguracionScreen(),
          },
        );
      },
    );
  }
}