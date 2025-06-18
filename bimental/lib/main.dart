import 'package:bimental/CofigurationUser.dart';
import 'package:bimental/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bimental/RegisterUserPage.dart';
import 'package:bimental/firebase_options.dart';
import 'ForgetPassword.dart';
import 'Home.dart';
import 'SignInAdm.dart';
import 'NotificationService.dart'; // Importa el servicio de notificaciones

// Lista en memoria para almacenar los usuarios registrados
List<Map<String, String>> usuariosRegistrados = [];

// Notificador global para manejar el tema oscuro
ValueNotifier<bool> isDarkModeEnabled = ValueNotifier(false);

// Manejador de notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    NotificationService().showNotification(
      message.notification!.title ?? 'Nueva notificación',
      message.notification!.body ?? 'Tienes un nuevo mensaje',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configurar Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Solicitar permisos para notificaciones
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Configurar el manejador de notificaciones en segundo plano
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar el servicio de notificaciones locales
  await NotificationService();

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
              bodyLarge: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A119B),
              ),
              bodyMedium: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A119B),
              ),
              bodySmall: TextStyle(
                color: isDark ? Colors.white : Color(0xFF1A119B),
              ),
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
