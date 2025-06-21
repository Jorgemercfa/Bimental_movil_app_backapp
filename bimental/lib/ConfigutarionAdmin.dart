import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bimental/main.dart'; // ValueNotifier isDarkModeEnabled

class ConfiguracionAdministracionScreen extends StatefulWidget {
  @override
  _ConfiguracionAdministracionScreenState createState() =>
      _ConfiguracionAdministracionScreenState();
}

class _ConfiguracionAdministracionScreenState
    extends State<ConfiguracionAdministracionScreen> {
  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkModeEnabled.value = prefs.getBool('isDarkModeEnabled') ?? false;
    });
  }

  void _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkModeEnabled.value = value;
    await prefs.setBool('isDarkModeEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeEnabled,
      builder: (context, isDark, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A119B),
            title: Text('Configuración', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Activar tema oscuro', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: isDark,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        _toggleDarkMode(value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
