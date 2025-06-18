import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A119B),
        automaticallyImplyLeading: false,
        title: Text(
          'Política de Privacidad',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('1. Introducción'),
            _buildSectionText(
                'Esta Política de Privacidad describe cómo nuestra aplicación móvil recopila, usa, almacena y protege la información de los usuarios en relación con la evaluación de los niveles de depresión, ansiedad y estrés basada en el cuestionario DASS-21.'),
            _buildSectionTitle('2. Información Recopilada'),
            _buildSectionText(
                '- Datos personales: Nombre, correo electrónico y contraseña para la creación de una cuenta.'),
            _buildSectionText(
                '- Respuestas al cuestionario DASS-21: Datos ingresados por el usuario durante la evaluación.'),
            _buildSectionText(
                '- Resultados de la evaluación: Nivel de depresión, ansiedad y estrés según el procesamiento del modelo de Machine Learning. Los resultados son aproximados y no constituyen un diagnóstico médico profesional.'),
            _buildSectionText(
                '- Datos de actividad: Registros de uso de la aplicación con fines de monitoreo.'),
            _buildSectionTitle('3. Uso de la Información'),
            _buildSectionText(
                'Los datos recopilados serán utilizados con los siguientes propósitos:'),
            _buildSectionText(
                '- Procesar las respuestas suministradas y generar resultados de triaje. Estos resultados son indicativos y deben ser interpretados por un profesional de salud mental.'),
            _buildSectionText(
                '- Proporcionar recomendaciones de contacto en caso de resultados positivos.'),
            _buildSectionText(
                '- Almacenar los resultados en la base de datos para monitoreo y generación de reportes por parte del administrador.'),
            _buildSectionText(
                '- Permitir que el administrador pueda contactar a los usuarios con resultados de nivel severo y/o extremadamente severo.'),
            _buildSectionText(
                '- Mejorar la funcionalidad de la aplicación y realizar análisis estadísticos anonimizados.'),
            _buildSectionTitle('4. Compartición de Datos'),
            _buildSectionText(
                'La información recopilada no será compartida con terceros, salvo en los siguientes casos:'),
            _buildSectionText(
                '- Cuando el usuario otorgue consentimiento explícito.'),
            _buildSectionText(
                '- Cuando sea requerido por ley o autoridad competente.'),
            _buildSectionText(
                '- Para proteger los derechos, seguridad e integridad de la aplicación y sus usuarios.'),
            _buildSectionTitle('5. Almacenamiento y Seguridad'),
            _buildSectionText(
                'Tomamos medidas de seguridad adecuadas para proteger la información del usuario contra accesos no autorizados, alteraciones o divulgaciones. La información se almacena en servidores seguros con tecnologías de cifrado y acceso restringido.'),
            _buildSectionTitle('6. Derechos del Usuario'),
            _buildSectionText('El usuario tiene derecho a:'),
            _buildSectionText(
                '- Acceder, rectificar o eliminar sus datos personales.'),
            _buildSectionText(
                '- Retirar su consentimiento para el procesamiento de datos.'),
            _buildSectionText(
                '- Solicitar información sobre el almacenamiento y uso de sus datos.'),
            _buildSectionText(
                'Para ejercer estos derechos, el usuario puede contactar al equipo de soporte a través del correo proporcionado en la aplicación.'),
            _buildSectionTitle('7. Cambios en la Política de Privacidad'),
            _buildSectionText(
                'Nos reservamos el derecho de modificar esta política en cualquier momento. Cualquier cambio será notificado a los usuarios mediante la aplicación o correo electrónico.'),
            _buildSectionTitle('8. Contacto'),
            _buildSectionText(
                'Si tienes preguntas sobre esta política, puedes contactarnos a través de serviciocliente@bimental.com.'),
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
                child:
                    const Text('Salir', style: TextStyle(color: Colors.white)),
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
