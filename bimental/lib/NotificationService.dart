import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Handler global para mensajes en segundo plano (debe estar fuera de cualquier clase)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa el plugin si es necesario
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Muestra la notificación local
  if (message.notification != null) {
    flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title ?? 'Notificación',
      message.notification!.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'admin_channel',
          'Administrador',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicialización recomendada
  Future<void> init(String adminId) async {
    // Registrar el handler de background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Solicitar permisos (iOS)
    await _fcm.requestPermission();

    // Obtener token del dispositivo y guardarlo en Firestore
    String? token = await _fcm.getToken();
    print("FCM Token: $token");
    if (token != null) {
      await saveAdminToken(adminId, token);
    }

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? 'Notificación',
          message.notification!.body ?? '',
        );
      }
    });

    // Escuchar cuando se abre la app desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Abrió desde notificación');
    });

    // Configuración para notificaciones locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notificación tocada: ${response.payload}');
        print('Acción seleccionada: ${response.actionId}');
      },
    );

    // Configuración de presentación en primer plano para iOS
    if (!kIsWeb && Platform.isIOS) {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    print('Servicio de notificaciones inicializado');
  }

  /// Muestra la notificación local
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'admin_channel',
      'Administrador',
      importance: Importance.max,
      priority: Priority.high,
      channelDescription: 'Canal para notificaciones de administración',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
      threadIdentifier: 'thread_id',
      categoryIdentifier: 'admin_category',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'payload_data',
    );

    print('Notificación mostrada: Título: $title, Cuerpo: $body');
  }
}

/// Guardar el token FCM del admin en Firestore
Future<void> saveAdminToken(String adminId, String token) async {
  await FirebaseFirestore.instance.collection('admin_tokens').doc(adminId).set({
    'token': token,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
