import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/publicacion_autoparte.dart';
import '../main.dart'; // Importamos para usar el navigatorKey en caso de sesión expirada

import 'dart:io'; // Necesario para el tipo 'File'
import 'dart:typed_data'; // SOLUCIÓN: Necesario para el tipo 'Uint8List'

class PublicacionService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  // SOLUCIÓN: Renombramos el método para que coincida con el llamado en home_screen.dart
  Future<List<PublicacionAutoparte>> getPublicacionesActivas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Endpoint correcto para obtener las publicaciones.
    final url = Uri.parse('$_baseUrl/api/publicaciones_autopartes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Es buena práctica enviar el token, aunque el endpoint sea público,
          // por si en el futuro se hace privado.
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Usamos el modelo correcto: PublicacionAutoparte
        return data.map((json) => PublicacionAutoparte.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Manejo de sesión expirada consistente.
        await prefs.remove('auth_token');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        throw Exception('Sesión expirada. Por favor, inicie sesión de nuevo.');
      } else {
        // Manejo de errores del servidor
        throw Exception('Fallo al cargar publicaciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // FUNCIÓN AÑADIDA: Para obtener los detalles de UNA SOLA publicación por su ID.
  Future<PublicacionAutoparte> getPublicacionById(String id) async {
    final token = await _getToken();
    // El nuevo endpoint que crearemos en el backend.
    final url = Uri.parse('$_baseUrl/api/publicaciones/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // La respuesta ahora es un solo objeto JSON, no una lista.
        final Map<String, dynamic> data = json.decode(response.body);
        return PublicacionAutoparte.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('La publicación no fue encontrada.');
      } else {
        throw Exception(
          'Fallo al cargar el detalle de la publicación: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception(
        'Error de conexión al obtener el detalle: ${e.toString()}',
      );
    }
  }

  // FUNCIÓN AÑADIDA: Para obtener las publicaciones del usuario autenticado.
  Future<List<PublicacionAutoparte>> getMisPublicaciones() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

    // Este será el nuevo endpoint en tu backend para esta funcionalidad.
    final url = Uri.parse('$_baseUrl/api/usuario/publicaciones');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PublicacionAutoparte.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Sesión expirada. Por favor, inicie sesión de nuevo.');
      } else {
        throw Exception('Fallo al cargar tus publicaciones: ${response.body}');
      }
    } catch (e) {
      throw Exception(
        'Error de conexión al obtener tus publicaciones: ${e.toString()}',
      );
    }
  }

  // FUNCIÓN AÑADIDA: Para crear una nueva publicación.
  Future<void> crearPublicacion({
    required String nombreParte,
    required int idCategoria,
    required double precio,
    required String condicion,
    required int stock,
    required String ubicacionCiudad,
    String? numeroOem,
    String? descripcionCorta,
    required String
    fotoUrl, // La URL de la imagen ya subida a un servicio externo.
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No estás autenticado para realizar esta acción.');
    }

    final url = Uri.parse('$_baseUrl/api/publicaciones');

    final body = jsonEncode({
      'nombre_parte': nombreParte,
      'id_categoria': idCategoria,
      'precio': precio,
      'condicion': condicion,
      'stock': stock,
      'ubicacion_ciudad': ubicacionCiudad,
      'numero_oem': numeroOem ?? '',
      'descripcion_corta': descripcionCorta ?? '',
      'foto_url': fotoUrl,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode != 201) {
        // Si el backend devuelve un error, lo lanzamos.
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Error desconocido del servidor.',
        );
      }
      // Si es 201, la operación fue exitosa y no necesitamos hacer más.
    } catch (e) {
      throw Exception('Fallo al crear la publicación: ${e.toString()}');
    }
  }

  // FUNCIÓN AÑADIDA: Para actualizar una publicación existente.
  Future<void> updatePublicacion({
    required String publicacionId,
    required String nombreParte,
    required int idCategoria,
    required double precio,
    required String condicion,
    required int stock,
    required String ubicacionCiudad,
    String? numeroOem,
    String? descripcionCorta,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No estás autenticado para realizar esta acción.');
    }

    // El endpoint para actualizar una publicación específica.
    final url = Uri.parse('$_baseUrl/api/publicaciones/$publicacionId');

    final body = jsonEncode({
      'nombre_parte': nombreParte,
      'id_categoria': idCategoria,
      'precio': precio,
      'condicion': condicion,
      'stock': stock,
      'ubicacion_ciudad': ubicacionCiudad,
      'numero_oem': numeroOem ?? '',
      'descripcion_corta': descripcionCorta ?? '',
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        // Si el backend devuelve un error, lo lanzamos.
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Error desconocido del servidor.',
        );
      }
      // Si es 200, la operación fue exitosa.
    } catch (e) {
      throw Exception('Fallo al actualizar la publicación: ${e.toString()}');
    }
  }

  // FUNCIÓN AÑADIDA: Para eliminar una publicación.
  Future<void> deletePublicacion(String publicacionId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No estás autenticado para realizar esta acción.');
    }

    final url = Uri.parse('$_baseUrl/api/publicaciones/$publicacionId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        // SOLUCIÓN: Verificamos si la respuesta es JSON antes de decodificarla.
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(
            errorBody['message'] ??
                'Error desconocido del servidor al eliminar.',
          );
        } catch (e) {
          // Si no es JSON, es probable que sea un error de "Ruta no encontrada" (404).
          throw Exception(
            'Error del servidor (código ${response.statusCode}). Es posible que la ruta para eliminar no exista en el backend.',
          );
        }
      }
      // Si es 200, la operación fue exitosa.
    } catch (e) {
      // Re-lanzamos la excepción para que la UI pueda manejarla.
      rethrow;
    }
  }

  // Método privado para obtener el token, para no duplicar código.
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // FUNCIÓN AÑADIDA: Para subir la imagen a un servicio externo.
  // NOTA: Esta es una implementación de EJEMPLO. Necesitarás una cuenta
  // en un servicio como Cloudinary para obtener una URL real.
  // SOLUCIÓN: Se cambia el parámetro de 'File' a 'Uint8List' y 'String' para ser compatible con web.
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    // --- IMPLEMENTACIÓN REAL CON CLOUDINARY ---

    // 1. **REEMPLAZA ESTOS VALORES CON LOS TUYOS**
    const String cloudName = 'dfej71ufs'; //nombre de mi cloud
    const String uploadPreset =
        'neumatik_uploads'; //configurado asi en cloudinary

    // 2. Configura la URL del servicio de Cloudinary.
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    // 3. Crea una petición 'multipart' para poder enviar el archivo.
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    // SOLUCIÓN: Usamos MultipartFile.fromBytes, que no depende de dart:io y funciona en web.
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    // 4. Envía la petición y espera la respuesta.
    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200) {
      // 5. Si la subida es exitosa, decodifica la respuesta JSON.
      final responseData = json.decode(response.body);
      // Cloudinary devuelve la URL en la clave 'secure_url'.
      return responseData['secure_url'];
    } else {
      // Si algo falla, lanza un error.
      throw Exception(
        'Fallo al subir la imagen a Cloudinary. Código: ${response.statusCode}',
      );
    }
  }
}
