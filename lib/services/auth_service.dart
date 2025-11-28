// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../models/usuario_autenticado.dart';

class AuthService {
  // URL base del backend.
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';
  static const String _tokenKey = 'auth_token';

  // Constantes para endpoints (COINCIDEN CON EL BACKEND DE EXPRESS.JS)
  final String _loginEndpoint = '/api/auth/login';
  final String _registerEndpoint = '/api/registro';
  final String _profileEndpoint =
      '/api/usuario/perfil'; // Nuevo endpoint para el perfil

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
      // Se usa 'contrasena' para coincidir con el backend JS
      'contrasena': contrasena,
      'telefono': telefono,
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

        // Asumiendo que el campo 'token' se encuentra en el nivel superior del body de respuesta.
        final authResult = UsuarioAutenticado.fromJson(responseBody);

        await _saveToken(authResult.token);

        return authResult;
      } else {
        // 2. Manejo de códigos de error (4xx, 5xx)
        String errorDetail =
            'Error desconocido (Código HTTP: ${response.statusCode})';

        try {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);

          errorDetail =
              responseBody['message'] ??
              responseBody['detail'] ??
              responseBody['error'] ??
              errorDetail;
        } on FormatException {
          errorDetail =
              'Error del servidor, no es formato JSON. Código: ${response.statusCode}';
        }

        throw Exception('Fallo al registrar usuario: $errorDetail');
      }
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      throw Exception( // Captura otros errores como timeouts o errores de formato.
        'Ocurrió un error inesperado durante el registro: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE LOGIN
  // --------------------------------------------------------------------------

  Future<UsuarioAutenticado> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    final url = Uri.parse('$_baseUrl$_loginEndpoint');
    final body = jsonEncode({'correo': correo, 'contrasena': contrasena});

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
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor para iniciar sesión. Verifica tu conexión.',
      );
    } on FormatException { // Este error es válido en todas las plataformas.
      throw Exception(
        'Respuesta inesperada del servidor (formato JSON inválido).',
      );
    } catch (e) {
      throw Exception(
        'Ocurrió un error inesperado durante el login: ${e.toString()}',
      );
    }
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE PERFIL DE USUARIO
  // --------------------------------------------------------------------------

  // Obtiene el perfil completo del usuario autenticado (requiere JWT)
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado. Inicie sesión primero.');
    }

    final url = Uri.parse('$_baseUrl$_profileEndpoint');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Enviar el token en el header
        },
      );

      if (response.statusCode == 200) {
        // Respuesta exitosa
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // El backend devuelve { perfil: {...datos_usuario}, mensaje: ... }
        if (responseBody.containsKey('perfil')) {
          // Devuelve el mapa con los datos del perfil (id, nombre, correo, etc.)
          return responseBody['perfil'];
        } else {
          throw Exception(
            'Respuesta de perfil válida, pero falta la clave "perfil".',
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token inválido o expirado -> Forzar cierre de sesión y notificar
        await logout();
        throw Exception(
          'Sesión expirada o token inválido. Vuelva a iniciar sesión.',
        );
      } else {
        // Otro error del servidor (ej. 500)
        String errorDetail = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ??
                  'Error desconocido del servidor.'
            : 'Error desconocido (Código HTTP: ${response.statusCode})';

        throw Exception('Fallo al cargar el perfil: $errorDetail');
      }
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      throw Exception( // Captura otros errores.
        'Ocurrió un error inesperado al obtener el perfil: ${e.toString()}',
      );
    }
  }
}
