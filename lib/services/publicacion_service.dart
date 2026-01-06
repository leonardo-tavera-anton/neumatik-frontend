import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/publicacion_autoparte.dart';
import '../main.dart'; //importamos para usar navigatorKey
//para el manejo d archivos
import 'dart:typed_data'; //para manejar bytes de imagenes

class PublicacionService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  //metodo para obtener todas las publicaciones activas
  Future<List<PublicacionAutoparte>> getPublicacionesActivas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    //ajustamos la URL del endpoint
    final url = Uri.parse('$_baseUrl/api/publicaciones_autopartes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          //es buena practica enviar el token si existe
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(
          response.body,
        ); //la respuesta es una lista
        return data.map((json) => PublicacionAutoparte.fromJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        //manejo de sesion expirada
        await prefs.remove('auth_token');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        throw Exception('Sesión expirada. Por favor, inicie sesión de nuevo.');
      } else {
        //manejo de otros errores
        throw Exception('Fallo al cargar publicaciones: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  //metodo para obtener el detalle de una publicacion por su id
  Future<PublicacionAutoparte> getPublicacionById(String id) async {
    final token = await _getToken();

    //ajustamos la URL del endpoint nuevo
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

  //funcion para obtener las publicaciones del usuario autenticado
  Future<List<PublicacionAutoparte>> getMisPublicaciones() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No estás autenticado.');
    }

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

  //funcion para crear una nueva publicacion
  Future<void> crearPublicacion({
    required String nombreParte,
    required int idCategoria,
    required double precio,
    required String condicion,
    required int stock,
    required String ubicacionCiudad,
    String? numeroOem,
    String? descripcionCorta,
    required String fotoUrl, //url de la foto ya subida
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
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Error desconocido del servidor.',
        );
      }
      //si es 201 la publicacion se creo correctamente
    } catch (e) {
      throw Exception('Fallo al crear la publicación: ${e.toString()}');
    }
  }

  //funcion para actualizar una publicacion existente
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

    //para actualizar usamos el endpoint con el id de la publicacion
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
        final errorBody = jsonDecode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Error desconocido del servidor.',
        );
      }
    } catch (e) {
      throw Exception('Fallo al actualizar la publicación: ${e.toString()}');
    }
  }

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
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(
            errorBody['message'] ??
                'Error desconocido del servidor al eliminar.',
          );
        } catch (e) {
          //si la respuesta no es json
          throw Exception(
            'Error del servidor (código ${response.statusCode}). Es posible que la ruta para eliminar no exista en el backend.',
          );
        }
      }
      //si es 200 se elimino correctamente
    } catch (e) {
      rethrow;
    }
  }

  //funcion privada para obtener el token de autenticacion
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //funcion para subir imagenes a cloudinary
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    // 1. Configura los parametros de Cloudinary
    const String cloudName = 'dfej71ufs'; //nombre de mi cloud
    const String uploadPreset =
        'neumatik_uploads'; //configurado asi en cloudinary

    // 2. Configura la URL del servicio de Cloudinary.
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    // 3. Crea una peticion multipart para poder enviar el archivo.
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    //agregamos el archivo a la peticion
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    // 4. Envia la peticion y espera la respuesta
    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200) {
      // 5. Procesa la respuesta para obtener la URL de la imagen subida
      final responseData = json.decode(response.body);
      //devuelve la URL segura de la imagen
      return responseData['secure_url'];
    } else {
      throw Exception(
        'Fallo al subir la imagen a Cloudinary. Código: ${response.statusCode}',
      );
    }
  }
}
