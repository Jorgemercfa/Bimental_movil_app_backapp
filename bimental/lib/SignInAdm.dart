import 'package:bimental/Administrators.dart';
import 'package:flutter/material.dart';
import 'ForgetPasswordAdmin.dart';
import 'HomeAdmin.dart';
import 'AdminRepository.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <-- IMPORTANTE

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiMental Administración',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SignInAdmin(),
        '/HomeAdmin': (context) => HomePageAdmin(),
        '/ForgetPasswordAdmin': (context) => ForgetPasswordPageAdmin(),
      },
    );
  }
}

class SignInAdmin extends StatefulWidget {
  const SignInAdmin({Key? key}) : super(key: key);

  @override
  _SignInAdminState createState() => _SignInAdminState();
}

class _SignInAdminState extends State<SignInAdmin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  final AdminRepository adminRepository = AdminRepository();

  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<Administrators> adminsRegistrados = await adminRepository.getAdmins();

        Administrators? adminEncontrado;
        for (var admin in adminsRegistrados) {
          if (admin.email == emailController.text.trim() &&
              admin.password == passwordController.text.trim()) {
            adminEncontrado = admin;
            break;
          }
        }

        if (adminEncontrado != null) {
          try {
            // Obtener y guardar el token FCM tras login exitoso
            String? token = await FirebaseMessaging.instance.getToken();
            if (token != null) {
              await adminRepository.updateAdminFcmToken(adminEncontrado.id, token);
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePageAdmin()),
            );
          } catch (e) {
            scaffoldKey.currentState?.showSnackBar(
              SnackBar(content: Text('Error al obtener token: ${e.toString()}')),
            );
          }
        } else {
          scaffoldKey.currentState?.showSnackBar(
            const SnackBar(content: Text('Correo o contraseña incorrectos')),
          );
        }
      } catch (e) {
        scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Color(0xFF1A119B)),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A119B)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BiMental Administración',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                labelText: 'Correo Electrónico',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su correo electrónico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                labelText: 'Contraseña',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 170,
                child: ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A119B),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 170,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgetPasswordPageAdmin(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A119B),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                  ),
                  child: const Text(
                    'Olvidé contraseña',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF1A119B)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      cursorColor: const Color(0xFF1A119B),
      style: const TextStyle(color: Color(0xFF1A119B)), // Color del texto
      validator: validator,
    );
  }
}
