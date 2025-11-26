// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io'; // Necesario para SocketException, esencial para manejo de red.
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart'; // Mantenemos el import de Usuario
import '../models/usuario_autenticado.dart';

class AuthService {
  // URL base del backend.
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';
  static const String _tokenKey = 'auth_token';

  // Constantes para endpoints
  final String _loginEndpoint = '/api/auth/login';
  final String _registerEndpoint = '/api/auth/register';

  // --------------------------------------------------------------------------
  // LÓGICA DE PERSISTENCIA (SharedPreferences) - Métodos privados
  // --------------------------------------------------------------------------

  // Guarda el token en el almacenamiento local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Obtiene el token del almacenamiento local
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Cierra sesión y elimina el token (Método público)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Verifica si el usuario tiene un token almacenado (Método público)
  Future<bool> isUserLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE REGISTRO
  // --------------------------------------------------------------------------

  Future<UsuarioAutenticado> registerUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String telefono,
    required bool esVendedor,
  }) async {
    final url = Uri.parse('$_baseUrl$_registerEndpoint');

    final body = jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'telefono': telefono,
      // Usamos 'es_vendedor' según la convención snake_case común en backends.
      'es_vendedor': esVendedor,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // 1. Manejo de respuesta exitosa (201 Created)
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final authResult = UsuarioAutenticado.fromJson(responseBody);

        await _saveToken(authResult.token);

        return authResult;
      } else {
        // 2. Manejo de códigos de error (4xx, 5xx)
        String errorDetail =
            'Error desconocido (Código HTTP: ${response.statusCode})';

        try {
          // Intentamos decodificar el JSON de error
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          // Buscamos mensajes de error típicos
          errorDetail =
              responseBody['message'] ??
              responseBody['detail'] ??
              responseBody['error'] ??
              errorDetail;
        } on FormatException {
          // El servidor devolvió un error (ej. 500) pero el cuerpo NO era JSON
          errorDetail =
              'Error del servidor, no es formato JSON. Código: ${response.statusCode}';
        }

        throw Exception('Fallo al registrar usuario: $errorDetail');
      }
    } on SocketException {
      // Error de conexión (offline, servidor no responde)
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      // Otros errores (ej. TimeoutException, etc.)
      throw Exception(
        'Ocurrió un error inesperado durante el registro: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE LOGIN
  // --------------------------------------------------------------------------

  // Mantenemos la firma con named arguments para compatibilidad con login_screen.dart
  Future<UsuarioAutenticado> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');
    final body = jsonEncode({
      // Usamos 'correo' y 'contrasena' ya que tu código de login_screen las usa
      // y coincide con la estructura de registro.
      'correo': correo,
      'contrasena': contrasena,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 200 OK: Inicio de sesión exitoso

        final authResult = UsuarioAutenticado.fromJson(responseBody);

        await _saveToken(authResult.token);

        return authResult;
      } else {
        // Manejar errores (ej: credenciales inválidas, 401 Unauthorized)
        final errorDetail =
            responseBody['message'] ??
            responseBody['detail'] ??
            responseBody['error'] ??
            'Credenciales inválidas o error desconocido.';
        throw Exception('Fallo al iniciar sesión: $errorDetail');
      }
    } on SocketException {
      // Error de conexión
      throw Exception(
        'No se pudo conectar con el servidor para iniciar sesión. Verifica tu conexión.',
      );
    } on FormatException {
      // Error si la respuesta no es JSON (ej. 500 error en el servidor)
      throw Exception(
        'Respuesta inesperada del servidor (formato JSON inválido).',
      );
    } catch (e) {
      // Otros errores
      throw Exception('Ocurrió un error de conexión: ${e.toString()}');
    }
  }
}
