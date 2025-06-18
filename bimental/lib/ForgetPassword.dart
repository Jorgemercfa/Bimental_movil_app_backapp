import 'package:bimental/UserRepository.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiMental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResetPasswordPage(),
    );
  }
}

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> cambiarContrasena(BuildContext context) async {
      if (_formKey.currentState!.validate()) {
        String email = emailController.text;
        String newPassword = newPasswordController.text;

        UserRepository userRepository = UserRepository.instance;
        bool success = await userRepository.updatePassword(email, newPassword);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña actualizada exitosamente'),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Olvidé Contraseña',
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
                'BiMental',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo del usuario',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                style: const TextStyle(
                  color: Color(0xFF1A119B),
                ), // Color del texto
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su correo electrónico';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña del usuario',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                style: const TextStyle(
                  color: Color(0xFF1A119B),
                ), // Color del texto
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nueva Contraseña del usuario',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                style: const TextStyle(
                  color: Color(0xFF1A119B),
                ), // Color del texto
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme la nueva contraseña';
                  }
                  if (value != newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => cambiarContrasena(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A119B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
