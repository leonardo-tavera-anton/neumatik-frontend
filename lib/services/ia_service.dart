// lib/services/ia_service.dart
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

class IAService {
  // --- ¡IMPORTANTE! ---
  // Reemplaza 'TU_API_KEY_DE_GEMINI' con tu clave de API real.
  // Obtén tu clave desde Google AI Studio: https://aistudio.google.com/app/apikey
  // ADVERTENCIA: NUNCA expongas esta clave en el código de una aplicación en producción.
  // Lo ideal es obtenerla desde un backend seguro. Para desarrollo, la usamos aquí.
  // el api se llama Clave App Neumatik Flutter tal cual hay 2 clouds pero solo uno es el correcto
  static const String _apiKey = 'AIzaSyA4xkgdjnIORnpVS5M2Lo0H6v0yhdc2iNA';

  final GenerativeModel _model;

  IAService()
    : _model = GenerativeModel(
        // Usamos el modelo 'gemini-2.0-flash', que está disponible en tu cuenta.
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
      );

  Future<String> analizarImagen(Uint8List imageBytes) async {
    try {
      // 1. Preparamos el "prompt" o la instrucción para la IA.
      // Le decimos qué queremos que haga con la imagen.
      final prompt = TextPart(
        "Eres un experto en reconocimiento de autopartes con una vista de águila. Tu misión es ser **extremadamente observador**. Examina cada rincón de la imagen, busca logos, números de serie, códigos, y cualquier texto o símbolo, por más pequeño que sea. Proporciona solo la información más valiosa y relevante en español. Sé extremadamente breve y directo. Tu respuesta debe ser una lista de datos clave, usando Markdown. Incluye únicamente los siguientes puntos:\n"
        "- **Marca:** (La marca de la pieza, si es visible. Este es el dato más importante).\n"
        "- **Nombre de la pieza:** (Ej: Pastilla de freno, Filtro de aceite).\n"
        "- **Modelo/Tipo:** (Si aplica, ej: para llantas, el modelo específico).\n"
        "- **Condición estimada:** (Nuevo, Usado, Desgastado).\n"
        "- **Número de Parte (OEM):** (Si es visible o claramente deducible).\n"
        "- **Fecha de Creación:** (Si se puede determinar por algún código en la pieza).\n"
        "- **Compatibilidad:** (Vehículos compatibles, si se conoce).\n\n"
        "**Instrucción final:** Si no puedes determinar con certeza alguno de estos datos, OMITE COMPLETAMENTE la línea correspondiente. No escribas 'No disponible' ni des explicaciones.",
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
