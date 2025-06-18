// import 'package:bimental/session_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'AnswersUser.dart';
import 'ManageAnswers.dart';
import 'User.dart';
import 'UserRepository.dart';

class AnswersRepository {
  static List<AnswersUser> answersHistory = [];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener TODOS los resultados globales (solo para administradores)
  static Future<List<AnswersUser>> getAllAnswersFromFirestore() async {
    try {
      List<AnswersUser> allAnswers = [];

      try {
        QuerySnapshot snapshot = await _firestore
            .collection('answers')
            .orderBy('timestamp', descending: true)
            .get();

        allAnswers = _processSnapshot(snapshot);
        print(
          "Historial completo obtenido de Firestore: ${allAnswers.length} registros",
        );
      } catch (e) {
        print("Error al obtener el historial completo de Firestore: $e");
        // Intento alternativo sin ordenamiento si falla
        try {
          QuerySnapshot snapshot = await _firestore.collection('answers').get();
          allAnswers = _processSnapshot(snapshot);
          allAnswers.sort((a, b) {
            // Manejo seguro para comparación de timestamps
            try {
              final dateA = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).parse(a.timestamp);
              final dateB = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).parse(b.timestamp);
              return dateB.compareTo(dateA);
            } catch (e) {
              print("Error al parsear fechas: $e");
              return b.timestamp.compareTo(a.timestamp);
            }
          });
        } catch (e) {
          print("Error en intento alternativo: $e");
        }
      }

      return allAnswers;
    } catch (e) {
      print("Error en la verificación de admin: $e");
      return [];
    }
  }

  // Guardar respuestas en Firestore
  static Future<void> saveAnswers(List<String> answers, String userId) async {
    print("Guardando respuestas para el usuario: $userId");
    print("Respuestas: $answers");

    User? user = UserRepository.instance.users.firstWhere(
      (u) => u.id == userId,
      orElse: () => User('', 'Desconocido', 'N/A', '', 'N/A', ''),
    );

    List<int> respuestas = answers.map((e) => int.tryParse(e) ?? 0).toList();
    print("Respuestas convertidas a enteros: $respuestas");

    Map<String, dynamic> puntajes = ManageAnswers.calcularResultados(
      respuestas,
      userId,
    );
    print("Puntajes calculados: $puntajes");

    DateTime now = DateTime.now();
    String timestampStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    AnswersUser newEntry = AnswersUser(
      userId: user.id,
      timestamp: timestampStr,
      p_depresion: puntajes['p_depresion'] ?? 0,
      p_ansiedad: puntajes['p_ansiedad'] ?? 0,
      p_estres: puntajes['p_estres'] ?? 0,
    );

    answersHistory.add(newEntry);
    print("Nueva entrada guardada localmente: $newEntry");

    try {
      // Guardado en la estructura principal
      await _firestore.collection('answers').add({
        'timestamp': now, // Guardar como DateTime
        'p_depresion': newEntry.p_depresion,
        'p_ansiedad': newEntry.p_ansiedad,
        'p_estres': newEntry.p_estres,
        'userId': userId,
      });

      // Guardado opcional en estructura optimizada por usuario
      try {
        await _firestore
            .collection('user_answers')
            .doc(userId)
            .collection('results')
            .add({
              'timestamp': now,
              'p_depresion': newEntry.p_depresion,
              'p_ansiedad': newEntry.p_ansiedad,
              'p_estres': newEntry.p_estres,
            });
      } catch (e) {
        print("Error al guardar en estructura optimizada: $e");
      }

      print("Datos guardados en Firestore correctamente.");
    } catch (e) {
      print("Error al guardar en Firestore: $e");
    }
  }

  // Obtener respuestas por usuario
  static Future<List<AnswersUser>> getAnswersFromFirestore(
    String userId,
  ) async {
    List<AnswersUser> userAnswers = [];

    try {
      // Consulta principal a la colección 'answers'
      QuerySnapshot snapshot = await _firestore
          .collection('answers')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      userAnswers = _processSnapshot(snapshot);
      print("Respuestas obtenidas: $userAnswers");
    } catch (e) {
      print("Error en consulta principal: $e. Intentando alternativas...");

      // Intento 1: Sin ordenamiento
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('answers')
            .where('userId', isEqualTo: userId)
            .get();

        userAnswers = _processSnapshot(snapshot);
        userAnswers.sort((a, b) {
          try {
            final dateA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.timestamp);
            final dateB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.timestamp);
            return dateB.compareTo(dateA);
          } catch (e) {
            return b.timestamp.compareTo(a.timestamp);
          }
        });
      } catch (e) {
        print("Error en intento sin ordenamiento: $e");

        // Intento 2: Estructura optimizada (user_answers)
        try {
          QuerySnapshot snapshot = await _firestore
              .collection('user_answers')
              .doc(userId)
              .collection('results')
              .orderBy('timestamp', descending: true)
              .get();

          userAnswers = _processSnapshot(snapshot, userId);
        } catch (e) {
          print("Error al obtener de estructura optimizada: $e");
        }
      }
    }

    return userAnswers;
  }

  // Procesar documentos de Firestore
  static List<AnswersUser> _processSnapshot(
    QuerySnapshot snapshot, [
    String? userId,
  ]) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Manejo de timestamp (DateTime, Timestamp o String)
      String timestamp;
      if (data['timestamp'] is DateTime) {
        timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(data['timestamp']);
      } else if (data['timestamp'] is Timestamp) {
        timestamp = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format((data['timestamp'] as Timestamp).toDate());
      } else {
        timestamp = data['timestamp']?.toString() ?? '';
      }

      return AnswersUser(
        userId: userId ?? data['userId'] ?? '',
        timestamp: timestamp,
        p_depresion: (data['p_depresion'] ?? 0).toInt(),
        p_ansiedad: (data['p_ansiedad'] ?? 0).toInt(),
        p_estres: (data['p_estres'] ?? 0).toInt(),
      );
    }).toList();
  }

  // Obtener respuestas locales
  static List<AnswersUser> getAnswers() {
    return answersHistory;
  }
}
