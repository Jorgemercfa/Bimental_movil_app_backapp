import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A119B),
        automaticallyImplyLeading: false,
        title: Text(
          'Términos y Condiciones',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('1. Introducción'),
            _buildSectionText(
                'Al utilizar esta aplicación móvil, usted acepta los términos y condiciones aquí descritos. Si no está de acuerdo con estos términos, por favor no utilice la aplicación.'),
            _buildSectionTitle('2. Uso de la Aplicación'),
            _buildSectionText(
                'La aplicación tiene como finalidad proporcionar un sistema de triaje basado en el cuestionario DASS-21. Los resultados proporcionados son aproximaciones generadas por algoritmos de Machine Learning y no constituyen un diagnóstico médico profesional. Deben ser utilizados únicamente como referencia y no sustituyen la evaluación de un profesional de salud mental calificado.'),
            _buildSectionText(
                'La exactitud de los resultados puede variar y la aplicación no asume responsabilidad por decisiones tomadas basadas en estos resultados. Se recomienda siempre consultar con un profesional de salud mental para una evaluación precisa.'),
            _buildSectionTitle('3. Almacenamiento de Datos'),
            _buildSectionText(
                'Los resultados de las evaluaciones serán almacenados en nuestra base de datos de forma segura. Estos datos podrán ser utilizados por los administradores de la aplicación para generar reportes y contactar a usuarios con resultados de nivel medio o grave.'),
            _buildSectionTitle('4. Privacidad y Seguridad'),
            _buildSectionText(
                'Nos comprometemos a proteger la información de los usuarios. Los datos recopilados no serán compartidos con terceros sin consentimiento, salvo en los casos requeridos por ley.'),
            _buildSectionTitle('5. Limitación de Responsabilidad'),
            _buildSectionText(
                'La aplicación no sustituye una consulta con un profesional de salud mental. El usuario es responsable del uso de la información proporcionada y comprende que los resultados son indicativos y no diagnósticos definitivos.'),
            _buildSectionText(
                'La aplicación no se hace responsable por acciones tomadas basadas en los resultados proporcionados, ni por cualquier consecuencia derivada de la interpretación de los mismos.'),
            _buildSectionTitle('6. Contacto'),
            _buildSectionText(
                'Si tiene alguna consulta sobre estos términos y condiciones, puede comunicarse con nuestro equipo de soporte.'),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A119B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text('Continuar',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
