// lib/services/ia_service.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // SOLUCIÓN: Importamos para especificar el tipo de contenido.
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
        // SOLUCIÓN: Especificamos explícitamente que estamos enviando una imagen JPEG.
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // 4. Enviamos la petición y obtenemos la respuesta.
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['analysis'] ?? 'No se recibió un análisis válido.';
      } else {
        // SOLUCIÓN: Si la respuesta no es 200, intentamos decodificar el error.
        // Si falla (porque es HTML), mostramos un error más claro.
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Error del servidor.');
        } catch (e) {
          throw Exception(
            'El servidor devolvió una respuesta inesperada (código ${response.statusCode}). Asegúrate de que el backend esté actualizado y funcionando.',
          );
        }
      }
    } catch (e) {
      throw Exception(
        'Error al comunicarse con el servicio de IA: ${e.toString()}',
      );
    }
  }

  // SOLUCIÓN: Se mueve el método dentro de la clase IAService para corregir los errores.
  Future<String> analizarParaCrear(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

    // Apuntamos al nuevo endpoint del backend.
    final url = Uri.parse('$_baseUrl/api/ia/analizar-para-crear');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token';

      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['analysis'] ?? 'No se recibió un análisis válido.';
      } else {
        // SOLUCIÓN: Se añade un manejo de errores robusto.
        // Si la respuesta no es JSON (es HTML), se captura el error y se muestra un mensaje claro.
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Error del servidor.');
        } catch (e) {
          throw Exception(
            'El servidor devolvió una respuesta inesperada (código ${response.statusCode}). Esto puede ocurrir si hay un error en el backend. Revisa los logs del servidor.',
          );
        }
      }
    } catch (e) {
      throw Exception(
        'Error al comunicarse con el servicio de IA: ${e.toString()}',
      );
    }
  }
}
