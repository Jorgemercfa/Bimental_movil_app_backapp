import 'package:flutter/material.dart';
import 'UserRepository.dart'; // Importar UserRepository

class CambiarDatosScreenUser extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController =
      TextEditingController(); // Nuevo controlador
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  CambiarDatosScreenUser({Key? key}) : super(key: key);

  void actualizarDatos(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final UserRepository userRepository = UserRepository();

      // Actualizar datos en Firestore
      bool success = await userRepository.updateUserData(
        _emailController.text,
        _nombresController.text,
        _apellidosController.text, // Nuevo campo
        _telefonoController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar los datos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actualizar Datos',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A119B),
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nombresController,
                style: const TextStyle(color: Color(0xFF1A119B)),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Nuevo campo para el apellido
              TextFormField(
                controller: _apellidosController,
                style: const TextStyle(color: Color(0xFF1A119B)),
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Color(0xFF1A119B)),
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
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
                controller: _telefonoController,
                style: const TextStyle(color: Color(0xFF1A119B)),
                decoration: const InputDecoration(
                  labelText: 'Número telefónico',
                  labelStyle: TextStyle(color: Color(0xFF1A119B)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                cursorColor: const Color(0xFF1A119B),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su número telefónico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => actualizarDatos(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A119B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Actualizar',
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
