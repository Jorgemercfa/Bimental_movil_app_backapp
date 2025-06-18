import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bimental/main.dart'; // ValueNotifier isDarkModeEnabled
// import 'NotificationService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionAdministracionScreen extends StatefulWidget {
  @override
  _ConfiguracionAdministracionScreenState createState() =>
      _ConfiguracionAdministracionScreenState();
}

class _ConfiguracionAdministracionScreenState
    extends State<ConfiguracionAdministracionScreen> {
  bool recibirNotificaciones = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recibirNotificaciones = prefs.getBool('recibirNotificaciones') ?? false;
      isDarkModeEnabled.value = prefs.getBool('isDarkModeEnabled') ?? false;
    });
  }

  Future<void> _saveAdminToken(String adminId, String? token) async {
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('admin_tokens')
          .doc(adminId)
          .set({'token': token, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  void _toggleNotificaciones(bool value) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      recibirNotificaciones = value;
    });

    await prefs.setBool('recibirNotificaciones', value);

    // Tu lógica de autenticación debe proveer el adminId actual, aquí lo simulamos:
    final String adminId =
        "admin_id_actual"; // <-- Corrige esto con tu lógica real

    if (!kIsWeb) {
      if (value) {
        // Guarda el token FCM en Firestore para notificaciones push reales
        String? token = await messaging.getToken();
        await _saveAdminToken(adminId, token);

        await messaging.subscribeToTopic('admin_notifications');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Suscrito a notificaciones')));
      } else {
        await messaging.unsubscribeFromTopic('admin_notifications');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No recibirás más notificaciones')),
        );
        // Si quieres, elimina el token de Firestore aquí
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La suscripción a temas no está disponible en la web'),
        ),
      );
    }
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recibir notificaciones',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: recibirNotificaciones,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        _toggleNotificaciones(value);
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
