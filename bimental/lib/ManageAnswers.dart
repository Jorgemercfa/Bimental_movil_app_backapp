import 'package:cloud_firestore/cloud_firestore.dart';

/// Gestión de resultados IA DASS-21 (texto libre, por usuario único)
class ManageAnswers {
  // --- ¡NO depende de AnswersUser! ---

  /// Guarda los resultados numéricos IA obtenidos del modelo en Firebase.
  /// [userId]: ID del usuario.
  /// [scores]: Mapa {'depresion': int, 'ansiedad': int, 'estres': int}
  static Future<void> saveUserAnswers(String userId, Map<String, int> scores) async {
    await FirebaseFirestore.instance.collection('answers').doc(userId).set({
      'depresion': scores['depresion'],
      'ansiedad': scores['ansiedad'],
      'estres': scores['estres'],
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
    }, SetOptions(merge: true));
  }

  /// Obtiene el resultado IA más reciente de un usuario.
  static Future<Map<String, dynamic>?> getUserAnswers(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('answers').doc(userId).get();
    if (doc.exists) return doc.data();
    return null;
  }

  /// Obtiene todos los resultados IA de todos los usuarios (admin).
  static Future<List<Map<String, dynamic>>> getAllUsersAnswers() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('answers').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['userId'] = doc.id;
      return data;
    }).toList();
  }

  /// (Opcional) Si necesitas calcular resultados de opción múltiple, aquí sigue el método legacy (NO necesario para IA puro)
  static Map<String, dynamic> calcularResultados(
      List<dynamic> rawAnswers, userId) {
    // ... mismo código legacy por compatibilidad
    if (rawAnswers.isEmpty) {
      throw ArgumentError("La lista de respuestas no puede ser nula o vacía.");
    }

    List<int> answers = [];
    for (var answer in rawAnswers) {
      try {
        int parsedAnswer = int.parse(answer.toString());
        answers.add(parsedAnswer);
      } catch (e) {
        throw FormatException("Las respuestas deben ser números enteros.");
      }
    }

    int calcularSuma(List<int> indices) {
      return indices
          .where((i) => i - 1 < answers.length)
          .map((i) => answers[i - 1])
          .fold(0, (a, b) => a + b);
    }

    int sumaDepresion = calcularSuma([3, 5, 10, 13, 16, 17, 21]);
    int sumaAnsiedad = calcularSuma([2, 4, 7, 9, 15, 19, 20]);
    int sumaEstres = calcularSuma([1, 6, 8, 11, 12, 14, 18]);

    String clasificarDepresion(int score) {
      if (score >= 14) return 'Extremadamente severa';
      if (score >= 11) return 'Severa';
      if (score >= 7) return 'Moderada';
      if (score >= 5) return 'Leve';
      return 'Sin depresión';
    }

    String clasificarAnsiedad(int score) {
      if (score >= 10) return 'Extremadamente severa';
      if (score >= 8) return 'Severa';
      if (score >= 5) return 'Moderada';
      if (score >= 4) return 'Leve';
      return 'Sin ansiedad';
    }

    String clasificarEstres(int score) {
      if (score >= 17) return 'Extremadamente severo';
      if (score >= 13) return 'Severo';
      if (score >= 10) return 'Moderado';
      if (score >= 8) return 'Leve';
      return 'Sin estrés';
    }

    return {
      'p_depresion': sumaDepresion,
      'p_ansiedad': sumaAnsiedad,
      'p_estres': sumaEstres,
      'clasificacion': {
        'Depresión': clasificarDepresion(sumaDepresion),
        'Ansiedad': clasificarAnsiedad(sumaAnsiedad),
        'Estrés': clasificarEstres(sumaEstres),
      }
    };
  }
}