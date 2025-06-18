import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey =
      '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';
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> obtenerRespuesta(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo', // Usa el modelo adecuado
          'messages': [
            {'role': 'user', 'content': mensaje}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'].toString();
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al procesar la solicitud: $e');
    }
  }
}
