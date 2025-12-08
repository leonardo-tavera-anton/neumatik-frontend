// lib/services/ia_service.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; //para especificar el tipo de contenido
import 'package:shared_preferences/shared_preferences.dart';

class IAService {
  static const String _baseUrl =
      'https://neumatik-backend.up.railway.app'; //URL base del backend

  Future<String> analizarImagen(Uint8List imageBytes) async {
    //analiza la imagen enviada
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

    //preparamos la URL del endpoint
    final url = Uri.parse('$_baseUrl/api/ia/analizar-imagen');

    try {
      //preparamos la peticion multipart
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token';

      final multipartFile = http.MultipartFile.fromBytes(
        'image', //nombre del campo esperado por el backend
        imageBytes,
        filename: 'upload.jpg', //nombre del archivo
        //especificamos el tipo de contenido
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      //enviamos la peticion
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['analysis'] ?? 'No se recibió un análisis válido.';
      } else {
        //manejo de errores robusto
        //si la respuesta no es json se captura el error y se muestra un mensaje claro
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

  //nuevo metodo para analizar imagen y crear autoparte
  Future<String> analizarParaCrear(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

    //preparamos la URL del endpoint
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
        //manejo de errores completo ahora si
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
