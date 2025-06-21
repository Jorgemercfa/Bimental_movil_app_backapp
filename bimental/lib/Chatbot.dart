import 'package:bimental/session_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert'; // Añadido para json
import 'package:flutter/services.dart'; // Añadido para rootBundle
import 'AnswersRepository.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// NUEVO: Importa ManageAnswers para guardar los resultados finales del DASS-21
import 'ManageAnswers.dart';

void main() => runApp(const ChatBotApp());

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _showQuestionnaire = false;
  int questionCategoryNumber = 1;
  late DASS21Predictor _predictor;
  bool _modelLoaded = false;

  // NUEVO: Guarda respuestas textuales para el cuestionario DASS-21
  List<String> dass21TextAnswers = [];

  @override
  void initState() {
    super.initState();
    _predictor = DASS21Predictor();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _predictor.loadModelAndTokenizer();
      setState(() {
        _modelLoaded = true;
      });
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  final Map<String, List<Map<String, String>>> _questions = {
    // ... (todas las preguntas sin cambios)
    // Las preguntas originales se mantienen aquí exactamente igual.
    "1": [
      {"id": "1.1", "texto": "1) Me costó mucho relajarme"},
      {"id": "1.2", "texto": "1) Me fue difícil relajarme"},
      {"id": "1.3", "texto": "1) Relajarme resultó ser un desafío"},
      {
        "id": "1.4",
        "texto": "1) Tuve problemas para encontrar un momento de relajación"
      }
    ],
    "2": [
      {"id": "2.1", "texto": "2) Me di cuenta que tenía la boca seca"},
      {"id": "2.2", "texto": "2) Noté que mi boca estaba seca"},
      {"id": "2.3", "texto": "2) Sentí sequedad en la boca"},
      {"id": "2.4", "texto": "2) Percibí que mi boca carecía de humedad"}
    ],
    "3": [
      {"id": "3.1", "texto": "3) No podía sentir ningún sentimiento positivo"},
      {
        "id": "3.2",
        "texto": "3) Me resultaba imposible experimentar emociones positivas"
      },
      {"id": "3.3", "texto": "3) No lograba sentirme bien emocionalmente"},
      {"id": "3.4", "texto": "3) No podía conectar con sentimientos agradables"}
    ],
    "4": [
      {
        "id": "4.1",
        "texto":
        "4) Se me hizo difícil respirar (p. ej., respiración excesivamente rápida o falta de aliento sin hacer esfuerzo físico)"
      },
      {"id": "4.2", "texto": "4) Tuve problemas para respirar de forma normal"},
      {"id": "4.3", "texto": "4) Sentí que me costaba tomar aire"},
      {
        "id": "4.4",
        "texto":
        "4) Experimenté dificultad al intentar respirar sin razón aparente"
      }
    ],
    "5": [
      {
        "id": "5.1",
        "texto": "5) Se me hizo difícil tomar la iniciativa para hacer cosas"
      },
      {"id": "5.2", "texto": "5) Me costó iniciar actividades por mi cuenta"},
      {
        "id": "5.3",
        "texto": "5) Sentí que no podía empezar cosas nuevas fácilmente"
      },
      {"id": "5.4", "texto": "5) Iniciar tareas fue complicado para mí"}
    ],
    "6": [
      {"id": "6.1", "texto": "6) Reaccioné exageradamente en ciertas situaciones"},
      {
        "id": "6.2",
        "texto": "6) Respondí de forma desproporcionada en algunas circunstancias"
      },
      {
        "id": "6.3",
        "texto":
        "6) Mi reacción en ciertas situaciones fue más intensa de lo normal"
      },
      {"id": "6.4", "texto": "6) Exageré mis respuestas en determinados momentos"}
    ],
    "7": [
      {"id": "7.1", "texto": "7) Tuve temblores (p. ej., en las manos)"},
      {"id": "7.2", "texto": "7) Sentí que mis manos temblaban"},
      {"id": "7.3", "texto": "7) Experimenté temblores físicos"},
      {
        "id": "7.4",
        "texto": "7) Noté movimientos involuntarios en mis extremidades"
      }
    ],
    "8": [
      {"id": "8.1", "texto": "8) Sentí que tenía muchos nervios"},
      {"id": "8.2", "texto": "8) Me sentí extremadamente nervioso"},
      {"id": "8.3", "texto": "8) Los nervios me dominaron en varias ocasiones"},
      {"id": "8.4", "texto": "8) Estuve inquieto y con mucha ansiedad"}
    ],
    "9": [
      {
        "id": "9.1",
        "texto":
        "9) Estuve preocupado por situaciones en las cuales podía entrar en pánico y hacer el ridículo"
      },
      {
        "id": "9.2",
        "texto":
        "9) Me angustié ante la posibilidad de perder el control y avergonzarme"
      },
      {
        "id": "9.3",
        "texto":
        "9) Temí encontrarme en situaciones donde pudiera entrar en pánico"
      },
      {
        "id": "9.4",
        "texto": "9) Me preocupaba pasar vergüenza por no controlar mi ansiedad"
      }
    ],
    "10": [
      {"id": "10.1", "texto": "10) Sentí que no tenía nada por lo que ilusionarme"},
      {"id": "10.2", "texto": "10) Sentí que no había nada que me motivara"},
      {"id": "10.3", "texto": "10) Me faltaba entusiasmo hacia el futuro"},
      {
        "id": "10.4",
        "texto": "10) Carecía de expectativas positivas que me alegraran"
      }
    ],
    "11": [
      {"id": "11.1", "texto": "11) Me sentí agitado"},
      {"id": "11.2", "texto": "11) Estuve inquieto y alterado"},
      {"id": "11.3", "texto": "11) Sentí que no podía estar en calma"},
      {"id": "11.4", "texto": "11) Me noté muy nervioso y acelerado"}
    ],
    "12": [
      {"id": "12.1", "texto": "12) Se me hizo difícil relajarme"},
      {"id": "12.2", "texto": "12) Relajarme fue complicado para mí"},
      {
        "id": "12.3",
        "texto": "12) Tuve problemas para alcanzar un estado de calma"
      },
      {"id": "12.4", "texto": "12) Me costó mucho encontrar tranquilidad"}
    ],
    "13": [
      {"id": "13.1", "texto": "13) Me sentí triste y deprimido"},
      {"id": "13.2", "texto": "13) Experimenté una sensación profunda de tristeza"},
      {"id": "13.3", "texto": "13) Me noté abatido y sin ánimos"},
      {"id": "13.4", "texto": "13) Estuve emocionalmente decaído"}
    ],
    "14": [
      {
        "id": "14.1",
        "texto":
        "14) No toleré nada que no me permitiera continuar con lo que estaba haciendo"
      },
      {
        "id": "14.2",
        "texto": "14) Me frustré con cualquier interrupción en mis actividades"
      },
      {
        "id": "14.3",
        "texto":
        "14) No pude soportar situaciones que afectaran mi ritmo de trabajo"
      },
      {
        "id": "14.4",
        "texto": "14) Me molestaba cualquier cosa que interrumpiera mis planes"
      }
    ],
    "15": [
      {"id": "15.1", "texto": "15) Sentí que estaba cercano a sentir pánico"},
      {
        "id": "15.2",
        "texto": "15) Percibí que estaba al borde de entrar en pánico"
      },
      {
        "id": "15.3",
        "texto": "15) Tuve la sensación de que un ataque de pánico era inminente"
      },
      {
        "id": "15.4",
        "texto": "15) Sentí que la ansiedad extrema estaba a punto de desbordarse"
      }
    ],
    "16": [
      {"id": "16.1", "texto": "16) No me pude entusiasmar por nada"},
      {"id": "16.2", "texto": "16) Nada lograba despertar mi interés"},
      {"id": "16.3", "texto": "16) No encontré motivación en ninguna actividad"},
      {"id": "16.4", "texto": "16) Carecía de entusiasmo por todo"}
    ],
    "17": [
      {"id": "17.1", "texto": "17) Sentí que valía muy poco como persona"},
      {
        "id": "17.2",
        "texto": "17) Percibí que mi valor personal era insignificante"
      },
      {"id": "17.3", "texto": "17) Me sentí menospreciado, incluso por mí mismo"},
      {"id": "17.4", "texto": "17) Creí que no tenía importancia como individuo"}
    ],
    "18": [
      {"id": "18.1", "texto": "18) Sentí que estaba muy irritable"},
      {"id": "18.2", "texto": "18) Me noté fácilmente molesto"},
      {"id": "18.3", "texto": "18) Estuve más propenso a la irritación"},
      {
        "id": "18.4",
        "texto": "18) Cualquier cosa pequeña me hacía perder la paciencia"
      }
    ],
    "19": [
      {
        "id": "19.1",
        "texto":
        "19) Sentí la actividad de mi corazón a pesar de no haber hecho ningún esfuerzo físico (p. ej., aumento de los latidos, sensación de palpitación o salto de los latidos)"
      },
      {"id": "19.2", "texto": "19) Percibí latidos acelerados sin razón aparente"},
      {
        "id": "19.3",
        "texto": "19) Sentí que mi corazón palpitaba con fuerza, incluso en reposo"
      },
      {
        "id": "19.4",
        "texto":
        "19) Noté un ritmo cardíaco irregular sin haber realizado ejercicio"
      }
    ],
    "20": [
      {"id": "20.1", "texto": "20) Tuve miedo sin razón"},
      {"id": "20.2", "texto": "20) Sentí temor sin un motivo específico"},
      {"id": "20.3", "texto": "20) Me asusté sin causa aparente"},
      {
        "id": "20.4",
        "texto": "20) Experimenté una sensación de miedo injustificado"
      }
    ],
    "21": [
      {"id": "21.1", "texto": "21) Sentí que la vida no tenía ningún sentido"},
      {"id": "21.2", "texto": "21) Percibí que mi existencia carecía de propósito"},
      {"id": "21.3", "texto": "21) Me parecía que todo en la vida era inútil"},
      {"id": "21.4", "texto": "21) Sentí que no había razones para seguir adelante"}
    ]
  };

  List<Map<String, String>> _selectedQuestions = [];
  List<String> answers = [];

  Map<String, String> _generateRandomQuestion() {
    final random = Random();
    final group = _questions[questionCategoryNumber.toString()];
    return group != null && group.isNotEmpty
        ? group[random.nextInt(group.length)]
        : {"id": "N/A", "texto": "No hay más preguntas disponibles"};
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (text.toLowerCase() == 'cuestionario') {
      final userId = await SessionService.getUserId();
      if (userId == null) {
        setState(() {
          _messages.add({
            'bot':
            "Debes iniciar sesión para realizar el cuestionario. Por favor, inicia sesión primero.",
          });
        });
        return;
      }

      setState(() {
        _showQuestionnaire = true;
        _selectedQuestions = [_generateRandomQuestion()];
        _controller.clear();
        questionCategoryNumber = 1;
        answers.clear();
        dass21TextAnswers.clear(); // NUEVO: Limpia respuestas textuales del DASS-21
      });
      return;
    }

    if (_showQuestionnaire) {
      // CAMBIO: Ahora acepta respuestas textuales (no sólo 0-3)
      dass21TextAnswers.add(text); // Guarda la respuesta textual

      questionCategoryNumber++;

      if (questionCategoryNumber <= _questions.length) {
        setState(() {
          _selectedQuestions = [_generateRandomQuestion()];
          _controller.clear();
        });
      } else {
        await _finishQuestionnaire(); // Cambiado a await para procesamiento asíncrono
      }
      return;
    }

    setState(() {
      _messages.add({'user': text});
      _controller.clear();
    });

    if (_modelLoaded) {
      try {
        final prediction = await _predictor.predict(text);
        setState(() {
          _messages.add({
            'bot':
            "Análisis completado. Resultados: Depresión: ${prediction[0].toStringAsFixed(2)}, Ansiedad: ${prediction[1].toStringAsFixed(2)}, Estrés: ${prediction[2].toStringAsFixed(2)}",
          });
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'bot':
            "Lo siento, ocurrió un error al analizar tu mensaje. Por favor, intenta de nuevo.",
          });
        });
      }
    } else {
      setState(() {
        _messages.add({
          'bot':
          "El modelo de análisis aún no está cargado. Por favor, espera un momento e intenta nuevamente.",
        });
      });
    }
  }

  Future<void> _finishQuestionnaire() async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      setState(() {
        _messages.add({
          'bot': "Error: Sesión no válida. No se guardarán las respuestas.",
        });
        _showQuestionnaire = false;
        _selectedQuestions = [];
        dass21TextAnswers.clear();
      });
      return;
    }

    try {
      // CAMBIO: Transforma respuestas textuales a valores numéricos usando el modelo antes de guardar
      if (_modelLoaded) {
        // Procesa cada respuesta textual con el modelo LSTM, y suma los scores finales
        double totalDepresion = 0;
        double totalAnsiedad = 0;
        double totalEstres = 0;
        for (String respuesta in dass21TextAnswers) {
          final pred = await _predictor.predict(respuesta);
          totalDepresion += pred[0];
          totalAnsiedad += pred[1];
          totalEstres += pred[2];
        }
        // Redondea los resultados finales
        final scores = {
          'depresion': totalDepresion.round(),
          'ansiedad': totalAnsiedad.round(),
          'estres': totalEstres.round(),
        };

        // Guarda el resultado global en Firebase usando ManageAnswers
        await ManageAnswers.saveUserAnswers(userId, scores);

        final timestamp = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(DateTime.now());
        setState(() {
          _messages.add({
            'bot':
            "✅ Cuestionario completado y guardado correctamente.\nResultados finales:\nDepresión: ${scores['depresion']}\nAnsiedad: ${scores['ansiedad']}\nEstrés: ${scores['estres']}\n📅 Fecha: $timestamp",
          });
          _showQuestionnaire = false;
          _selectedQuestions = [];
        });
      } else {
        setState(() {
          _messages.add({
            'bot': "El modelo no está cargado. No se pueden guardar resultados.",
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'bot':
          "❌ Error al guardar el cuestionario. Por favor, intenta nuevamente.",
        });
      });
    } finally {
      dass21TextAnswers.clear();
      print("El id del usuario que realizo el cuestionario es: $userId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A119B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Para activar el cuestionario, escriba "cuestionario"',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message.containsKey('user');
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.green[600]
                          : Colors.green[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isUserMessage ? 12 : 0),
                        bottomRight: Radius.circular(isUserMessage ? 0 : 12),
                      ),
                    ),
                    child: Text(
                      isUserMessage ? message['user']! : message['bot']!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showQuestionnaire) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _selectedQuestions.first['texto']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Text(
                    'Responde a la pregunta en tus propias palabras (texto libre).',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _finishQuestionnaire,
                    child: const Text("Finalizar Cuestionario"),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: const Color(0xFF1A119B),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color(0xFF1A119B),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: TextField(
                                controller: _controller,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Color(0xFF1A119B),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Escribe un texto",
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DASS21Predictor {
  late Interpreter _interpreter;
  late Map<String, dynamic> _tokenizer;
  final int _maxLen = 100;

  Future<void> loadModelAndTokenizer() async {
    // Cargar modelo
    _interpreter = await Interpreter.fromAsset(
      'assets/model/lstm_daas21_model.tflite',
    );

    // Cargar tokenizer
    final tokenizerData = await rootBundle.loadString(
      'assets/model/tokenizer_daas21.json',
    );
    _tokenizer = json.decode(tokenizerData)['config']['word_index'];
  }

  List<int> tokenizeInput(String input) {
    final words = input.toLowerCase().split(' ');
    final tokens = words.map((w) => _tokenizer[w] ?? 0).toList();

    // Padding
    if (tokens.length < _maxLen) {
      tokens.addAll(List.filled(_maxLen - tokens.length, 0));
    } else if (tokens.length > _maxLen) {
      tokens.removeRange(_maxLen, tokens.length);
    }

    return tokens.cast<int>();
  }

  Future<List<double>> predict(String text) async {
    final input = tokenizeInput(text);
    final inputTensor = [input];

    var output = List.filled(1 * 3, 0).reshape([1, 3]);

    _interpreter.run(inputTensor, output);

    return List<double>.from(output[0]);
  }
}