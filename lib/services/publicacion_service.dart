import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publicacion.dart';
// Importado para claridad

// URL base de tu API (ejemplo)
const String _baseUrl = 'https://neumatik-backend.up.railway.app';

class PublicacionService {
  // Función para obtener todas las publicaciones para el listado
  Future<List<Publicacion>> fetchPublicaciones() async {
    try {
      // Endpoint para obtener todas las publicaciones
      final response = await http.get(Uri.parse('$_baseUrl/publicaciones'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Mapea la lista de JSON a objetos Publicacion
        return data.map((json) => Publicacion.fromJson(json)).toList();
      } else {
        // Manejo de errores del servidor
        throw Exception(
          'Fallo al cargar publicaciones. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Manejo de errores de red o parsing
      throw Exception('Error de conexión o formato de datos: $e');
    }
  }

  // Función para obtener el detalle de una publicación específica por ID
  Future<Publicacion> fetchPublicacionDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/publicaciones/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Retorna un objeto Publicacion, que incluye la lista de fotos
        return Publicacion.fromJson(data);
      } else {
        throw Exception(
          'Fallo al cargar el detalle de la publicación. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener el detalle: $e');
    }
  }
}
