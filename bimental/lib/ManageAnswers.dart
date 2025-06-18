class ManageAnswers {
  // Índices de las preguntas para cada categoría
  static const List<int> depresionIndices = [3, 5, 10, 13, 16, 17, 21];
  static const List<int> ansiedadIndices = [2, 4, 7, 9, 15, 19, 20];
  static const List<int> estresIndices = [1, 6, 8, 11, 12, 14, 18];

  /// Calcula los resultados del cuestionario basado en las respuestas proporcionadas.
  ///
  /// [rawAnswers]: Lista de respuestas (pueden ser enteros o strings que representen enteros).
  /// Retorna un mapa con las puntuaciones y clasificaciones de depresión, ansiedad y estrés.
  static Map<String, dynamic> calcularResultados(
      List<dynamic> rawAnswers, userId) {
    // Validar que las respuestas no sean nulas o estén vacías
    if (rawAnswers.isEmpty) {
      throw ArgumentError("La lista de respuestas no puede ser nula o vacía.");
    }

    // Convertir las respuestas a enteros
    List<int> answers = [];
    for (var answer in rawAnswers) {
      try {
        int parsedAnswer = int.parse(answer.toString());
        answers.add(parsedAnswer);
      } catch (e) {
        throw FormatException("Las respuestas deben ser números enteros.");
      }
    }

    // Función para calcular la suma de las respuestas basada en los índices proporcionados
    int calcularSuma(List<int> indices) {
      return indices
          .where((i) =>
              i - 1 <
              answers.length) // Validar que el índice esté dentro del rango
          .map((i) => answers[i - 1]) // Obtener la respuesta correspondiente
          .fold(0, (a, b) => a + b); // Sumar las respuestas
    }

    // Calcular las sumas para cada categoría
    int sumaDepresion = calcularSuma(depresionIndices);
    int sumaAnsiedad = calcularSuma(ansiedadIndices);
    int sumaEstres = calcularSuma(estresIndices);

    // Clasificar los resultados basados en las puntuaciones
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

    // Retornar los resultados
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
