// import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Añadido para json

class DASS21Predictor {
  late Interpreter _interpreter;
  late Map<String, dynamic> _tokenizer;
  final int _maxLen = 100; // Ajustar si es necesario

  Future<void> loadModelAndTokenizer() async {
    // Cargar modelo
    _interpreter =
        await Interpreter.fromAsset('assets/model/lstm_daas21_model.tflite');

    // Cargar tokenizer
    final tokenizerData =
        await rootBundle.loadString('assets/model/tokenizer_daas21.json');
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

    var output =
        List.filled(1 * 3, 0).reshape([1, 3]); // Ajusta a tu salida esperada

    _interpreter.run(inputTensor, output);

    return List<double>.from(output[0]);
  }
}
