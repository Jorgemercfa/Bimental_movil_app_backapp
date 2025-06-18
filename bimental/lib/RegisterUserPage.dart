import 'package:bimental/TermsAndConditionsScreen.dart';
import 'package:bimental/UserRepository.dart';
import 'package:flutter/material.dart';
import 'User.dart';

class RegisterUserPage extends StatefulWidget {
  RegisterUserPage({Key? key}) : super(key: key);

  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // NUEVO

  bool _termsAccepted = false;

  void registrarUsuario(BuildContext context) {
    if (_formKey.currentState!.validate() && _termsAccepted) {
      final edad = int.tryParse(_ageController.text);
      if (edad != null && edad < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes tener al menos 18 años para registrarte'),
          ),
        );
        return;
      }

      final UserRepository userRepository = UserRepository();
      User user = User(
        "",
        _nameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text,
      );
      userRepository.addUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado exitosamente')),
      );

      Navigator.pop(context);
    } else if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ageController.dispose(); // NUEVO
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar Usuario',
          style: TextStyle(color: Color(0xFF1A119B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A119B)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BiMental',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su edad';
                    }
                    final edad = int.tryParse(value);
                    if (edad == null || edad < 18) {
                      return 'Debes tener al menos 18 años para registrarte';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
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
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Celular',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su número de celular';
                    }
                    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                      return 'Ingrese un número de celular válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: TextStyle(color: Color(0xFF1A119B)),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: const Color(0xFF1A119B),
                  style: const TextStyle(color: Color(0xFF1A119B)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme su contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (val) {
                          setState(() {
                            _termsAccepted = val ?? false;
                          });
                        },
                        activeColor: const Color(0xFF1A119B),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsAndConditionsScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Acepto los ',
                            style: TextStyle(color: Color(0xFF1A119B)),
                            children: [
                              TextSpan(
                                text: 'Términos y Condiciones',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => registrarUsuario(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A119B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
