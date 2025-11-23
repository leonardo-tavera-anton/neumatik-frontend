// Archivo: lib/services/data_service.dart
//Este servicio se encargará de hacer la petición HTTP al nuevo endpoint de tu API de Railway.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publicacion_autoparte.dart';

// URL BASE DE TU BACKEND EN RAILWAY
const String baseUrl = 'https://neumatik-backend.up.railway.app';

class DataService {
  /// Obtiene la lista completa de publicaciones de autopartes activas.
  Future<List<PublicacionAutoparte>> getPublicacionesActivas() async {
    // Usamos el nuevo endpoint creado en index.js
    final url = Uri.parse('$baseUrl/api/publicaciones_autopartes');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        ); // Decodificación segura
        return jsonList
            .map((json) => PublicacionAutoparte.fromJson(json))
            .toList();
      } else {
        // En caso de error HTTP (400, 500, etc.)
        throw Exception(
          'Error al cargar datos: Código ${response.statusCode}. Respuesta: ${response.body}',
        );
      }
    } catch (e) {
      // En caso de fallo de red (servidor caído, sin internet)
      throw Exception('Fallo de red al conectar con el backend: $e');
    }
  }
}
