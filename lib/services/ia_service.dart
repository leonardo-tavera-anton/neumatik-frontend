// lib/services/ia_service.dart
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class IAService {
  // --- ¡IMPORTANTE! ---
  // Reemplaza 'TU_API_KEY_DE_GEMINI' con tu clave de API real.
  // Obtén tu clave desde Google AI Studio: https://aistudio.google.com/app/apikey
  // ADVERTENCIA: NUNCA expongas esta clave en el código de una aplicación en producción.
  // Lo ideal es obtenerla desde un backend seguro. Para desarrollo, la usamos aquí.
  static const String _apiKey = 'TU_API_KEY_DE_GEMINI';

  final GenerativeModel _model;

  IAService()
    : _model = GenerativeModel(
        // Usamos el modelo 'gemini-pro-vision', que acepta imágenes y texto.
        model: 'gemini-pro-vision',
        apiKey: _apiKey,
      );

  Future<String> analizarImagen(Uint8List imageBytes) async {
    try {
      // 1. Preparamos el "prompt" o la instrucción para la IA.
      // Le decimos qué queremos que haga con la imagen.
      final prompt = TextPart(
        "Analiza la siguiente imagen de una autoparte de vehículo. Proporciona un análisis detallado que incluya:\n"
        "- Nombre de la parte detectada.\n"
        "- Posible número de parte (OEM), si es visible o deducible.\n"
        "- Material principal.\n"
        "- Condición estimada (nuevo, usado, nivel de desgaste).\n"
        "- Posible compatibilidad con marcas o modelos de vehículos.\n"
        "- Una conclusión final sobre la pieza.\n"
        "Formatea la respuesta de manera clara y profesional usando Markdown.",
      );

      // 2. Preparamos la imagen para ser enviada.
      final imagePart = DataPart('image/jpeg', imageBytes);

      // 3. Enviamos la petición a la IA con el texto y la imagen.
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      // 4. Devolvemos la respuesta de texto generada por el modelo.
      return response.text ?? 'No se pudo obtener una respuesta de la IA.';
    } catch (e) {
      // Manejo de errores de la API.
      throw Exception(
        'Error al comunicarse con el servicio de IA: ${e.toString()}',
      );
    }
  }
}
