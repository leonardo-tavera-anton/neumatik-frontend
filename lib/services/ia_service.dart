// lib/services/ia_service.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IAService {
  // La URL base de tu backend.
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  Future<String> analizarImagen(Uint8List imageBytes) async {
    // 1. Obtenemos el token de autenticación del usuario.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

    // 2. Apuntamos a nuestro nuevo endpoint seguro en el backend.
    final url = Uri.parse('$_baseUrl/api/ia/analizar-imagen');

    try {
      // 3. Creamos una petición 'multipart' para enviar la imagen.
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token';

      final multipartFile = http.MultipartFile.fromBytes(
        'image', // El nombre del campo debe coincidir con el del backend: upload.single('image')
        imageBytes,
        filename: 'upload.jpg', // Un nombre de archivo genérico es suficiente.
      );
      request.files.add(multipartFile);

      // 4. Enviamos la petición y obtenemos la respuesta.
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['analysis'] ?? 'No se recibió un análisis válido.';
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error del servidor.');
      }
    } catch (e) {
      throw Exception(
        'Error al comunicarse con el servicio de IA: ${e.toString()}',
      );
    }
  }
}
