import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

// Usamos la misma URL base
const String _baseUrl = 'https://neumatik-backend.up.railway.app';

class UsuarioService {
  // Obtener detalles de un usuario por ID
  Future<Usuario> fetchUsuario(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/usuarios/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Usuario.fromJson(data);
      } else {
        throw Exception(
          'Fallo al cargar el usuario. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener el usuario: $e');
    }
  }
}
