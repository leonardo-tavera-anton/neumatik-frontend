// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences: ^2.2.2 en el pubspec.yaml
import '../models/usuario_autenticado.dart';

class AuthService {
  // Tu URL base de backend
  final String _baseUrl = 'https://neumatik-backend.up.railway.app';
  final String _loginEndpoint = '/api/auth/login'; // Ajusta el endpoint real

  // Clave de almacenamiento local para el token
  static const String _tokenKey = 'authToken';

  // ====================================================================
  // 1. Lógica de Inicio de Sesión
  // ====================================================================

  Future<UsuarioAutenticado> login(String correo, String contrasena) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Ajusta las claves 'correo' y 'contrasena' para que coincidan con tu backend
          'email': correo,
          'password': contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Crea la instancia del modelo
        final usuarioAutenticado = UsuarioAutenticado.fromJson(responseBody);

        // Guarda el token para futuras sesiones
        await _saveToken(usuarioAutenticado.token);

        return usuarioAutenticado;
      } else if (response.statusCode == 401) {
        // Código de estado típico para credenciales inválidas
        throw Exception(
          'Credenciales inválidas. Por favor, verifica tu correo y contraseña.',
        );
      } else {
        // Otros errores del servidor
        final errorDetail =
            jsonDecode(response.body)['detail'] ?? 'Error desconocido';
        throw Exception('Fallo al iniciar sesión: $errorDetail');
      }
    } catch (e) {
      // Errores de red o de otro tipo
      throw Exception('Ocurrió un error de conexión: $e');
    }
  }

  // ====================================================================
  // 2. Gestión del Token (Persistencia)
  // ====================================================================

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Puedes agregar más lógica de limpieza si es necesario
  }

  // ====================================================================
  // 3. Verificación de Estado de Sesión
  // ====================================================================

  // Útil para decidir si mostrar la pantalla de Login o la Home al iniciar la app
  Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    // Simplemente verifica si hay un token almacenado.
    // Una implementación más robusta debería validar la vigencia del token con el backend.
    return token != null;
  }
}
