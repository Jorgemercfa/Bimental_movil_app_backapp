import 'package:bimental/AnswersUser.dart';
import 'package:bimental/session_service.dart';
import 'package:bimental/session_services.dart'; // <--- CORREGIDO
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'AnswersRepository.dart';
import 'ManageAnswers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Resultados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HistorialResultadosScreen(),
    );
  }
}

// --- FUNCIÓN DE CLASIFICACIÓN LOCAL ---
Map<String, String> clasificarResultados(int depresion, int ansiedad, int estres) {
  String clasificacionDepresion;
  if (depresion >= 14) {
    clasificacionDepresion = 'Extremadamente severa';
  } else if (depresion >= 11) {
    clasificacionDepresion = 'Severa';
  } else if (depresion >= 7) {
    clasificacionDepresion = 'Moderada';
  } else if (depresion >= 5) {
    clasificacionDepresion = 'Leve';
  } else {
    clasificacionDepresion = 'Sin depresión';
  }

  String clasificacionAnsiedad;
  if (ansiedad >= 10) {
    clasificacionAnsiedad = 'Extremadamente severa';
  } else if (ansiedad >= 8) {
    clasificacionAnsiedad = 'Severa';
  } else if (ansiedad >= 5) {
    clasificacionAnsiedad = 'Moderada';
  } else if (ansiedad >= 4) {
    clasificacionAnsiedad = 'Leve';
  } else {
    clasificacionAnsiedad = 'Sin ansiedad';
  }

  String clasificacionEstres;
  if (estres >= 17) {
    clasificacionEstres = 'Extremadamente severo';
  } else if (estres >= 13) {
    clasificacionEstres = 'Severo';
  } else if (estres >= 10) {
    clasificacionEstres = 'Moderado';
  } else if (estres >= 8) {
    clasificacionEstres = 'Leve';
  } else {
    clasificacionEstres = 'Sin estrés';
  }

  return {
    'Depresión': clasificacionDepresion,
    'Ansiedad': clasificacionAnsiedad,
    'Estrés': clasificacionEstres,
  };
}

class HistorialResultadosScreen extends StatefulWidget {
  @override
  _HistorialResultadosScreenState createState() =>
      _HistorialResultadosScreenState();
}

class _HistorialResultadosScreenState extends State<HistorialResultadosScreen> {
  List<Map<String, dynamic>> resultados = [];
  bool isLoading = true;
  String? errorMessage;
  List<String> dass21TextAnswers = [];
  bool _showQuestionnaire = false;

  @override
  void initState() {
    super.initState();
    _cargarResultados();
  }

  void _cargarResultados() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userId = await SessionService.getUserId();
      if (userId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Debes iniciar sesión para ver tus resultados';
        });
        return;
      }

      List<AnswersUser> data =
      await AnswersRepository.getAnswersFromFirestore(userId);

      List<Map<String, dynamic>> nuevosResultados = data.map((result) {
        String fecha = '';
        String hora = '';
        if (result.timestamp.contains(' ')) {
          fecha = result.timestamp.split(' ')[0];
          hora = result.timestamp.split(' ')[1];
        }

        return {
          'fecha': fecha,
          'hora': hora,
          'p_depresion': result.p_depresion,
          'p_ansiedad': result.p_ansiedad,
          'p_estres': result.p_estres,
          'clasificacion': clasificarResultados(
              result.p_depresion, result.p_ansiedad, result.p_estres), // <--- CORREGIDO
        };
      }).toList();

      setState(() {
        resultados = nuevosResultados;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
        'Error al cargar tus resultados. Por favor, intenta nuevamente.';
        if (kDebugMode) {
          errorMessage = 'Error: ${e.toString()}';
        }
      });
    }
  }

  Future<void> _finalizarCuestionario() async {
    String? userId = await SessionService.getUserId();
    if (userId == null) {
      setState(() {
        errorMessage = 'Debes iniciar sesión para guardar tus resultados';
      });
      return;
    }

    try {
      Map<String, int> scores = await DASS21Predictor.predictScoresFromTextList(dass21TextAnswers);
      await ManageAnswers.saveUserAnswers(userId, scores);

      setState(() {
        dass21TextAnswers.clear();
        _showQuestionnaire = false;
      });

      _cargarResultados();
    } catch (e) {
      setState(() {
        errorMessage = 'Error al guardar los resultados: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis resultados', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A119B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showQuestionnaire = true;
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF1A119B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showQuestionnaire
            ? _buildQuestionnaireWidget()
            : _buildResultsWidget(),
      ),
    );
  }

  Widget _buildQuestionnaireWidget() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: 21,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  onChanged: (value) {
                    if (dass21TextAnswers.length <= index) {
                      dass21TextAnswers.add(value);
                    } else {
                      dass21TextAnswers[index] = value;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Respuesta a la pregunta ${index + 1}',
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _finalizarCuestionario,
          child: Text('Finalizar cuestionario'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1A119B), // <-- CORREGIDO
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResultsWidget() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : errorMessage != null
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          errorMessage!,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    )
        : resultados.isEmpty
        ? Center(
      child: Text(
        'No hay resultados guardados.',
        style: TextStyle(fontSize: 18),
      ),
    )
        : ListView.builder(
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        final resultado = resultados[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultadoDetalleScreen(
                  fecha: resultado['fecha'],
                  hora: resultado['hora'],
                  detalles: resultado,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFF1A119B),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.insert_chart,
                    color: Colors.white, size: 30),
                SizedBox(width: 16),
                Text(
                  '${resultado['fecha']} ${resultado['hora']}',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ResultadoDetalleScreen extends StatelessWidget {
  final String fecha;
  final String hora;
  final Map<String, dynamic> detalles;

  ResultadoDetalleScreen({
    required this.fecha,
    required this.hora,
    required this.detalles,
  });

  @override
  Widget build(BuildContext context) {
    final clasificacion = detalles['clasificacion'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del resultado',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A119B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nivel de depresión: ${clasificacion['Depresión']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Nivel de ansiedad: ${clasificacion['Ansiedad']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Nivel de estrés: ${clasificacion['Estrés']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}