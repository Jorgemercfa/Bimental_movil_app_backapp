import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:convert';

/// Predictor IA para texto libre DASS-21.
/// ¡No depende de AnswersUser!
class DASS21Predictor {
  late Interpreter _interpreter;
  late Map<String, dynamic> _tokenizer;
  final int _maxLen = 100;

  Future<void> loadModelAndTokenizer() async {
    _interpreter =
    await Interpreter.fromAsset('assets/model/lstm_daas21_model.tflite');
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
    var output = List.filled(1 * 3, 0).reshape([1, 3]);
    _interpreter.run(inputTensor, output);
    return List<double>.from(output[0]);
  }

  /// Procesa una lista de respuestas textuales y retorna los scores sumados y redondeados
  static Future<Map<String, int>> predictScoresFromTextList(
      List<String> respuestas) async {
    final predictor = DASS21Predictor();
    await predictor.loadModelAndTokenizer();

    double totalDepresion = 0;
    double totalAnsiedad = 0;
    double totalEstres = 0;

    for (String respuesta in respuestas) {
      final pred = await predictor.predict(respuesta);
      totalDepresion += pred[0];
      totalAnsiedad += pred[1];
      totalEstres += pred[2];
    }

    return {
      'depresion': totalDepresion.round(),
      'ansiedad': totalAnsiedad.round(),
      'estres': totalEstres.round(),
    };
  }
}