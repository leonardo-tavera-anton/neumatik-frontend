// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io'; // Necesario para SocketException, esencial para manejo de red.
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

  // FUNCIÓN AÑADIDA: Obtiene el ID del usuario desde el token.
  Future<String?> getCurrentUserId() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload['id'];
    } catch (e) {
      return null;
    }
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
        // SOLUCIÓN: Validar si la respuesta tiene cuerpo antes de decodificar.
        if (response.body.isEmpty) {
          throw Exception(
            'Error en el registro. El servidor respondió con un error pero sin detalles (Código: ${response.statusCode})',
          );
        }

        // SOLUCIÓN: Manejar respuestas de error que no son JSON.
        // Intentamos decodificar, si falla, usamos el cuerpo de la respuesta como texto plano.
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              errorBody['error'] ??
              'Ocurrió un error desconocido.';
          throw Exception(errorMessage);
        } catch (e) {
          // Si no es JSON, el cuerpo de la respuesta es el error (ej. "Credenciales inválidas").
          throw Exception(response.body);
        }
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      throw Exception(
        'Fallo al registrar usuario: ${e.toString().replaceFirst("Exception: ", "")}',
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

      if (response.statusCode == 200) {
        // 200 OK: Inicio de sesión exitoso
        // SOLUCIÓN: Añadimos un try-catch aquí porque el servidor podría enviar
        // un 200 OK con un cuerpo que no es JSON, causando el error.
        try {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final authResult = UsuarioAutenticado.fromJson(responseBody);

          await _saveToken(authResult.token);

          return authResult;
        } catch (e) {
          // Si el servidor envía 200 OK pero el cuerpo no es JSON, lo capturamos.
          throw Exception(
            'El servidor dio una respuesta inesperada. Cuerpo: ${response.body}',
          );
        }
      } else {
        // Manejo de errores (401, 400, etc.)
        // SOLUCIÓN: Validar si la respuesta tiene cuerpo antes de decodificar.
        if (response.body.isEmpty) {
          throw Exception(
            'Credenciales inválidas o error del servidor (Código: ${response.statusCode})',
          );
        }

        // SOLUCIÓN: Manejar respuestas de error que no son JSON.
        // Intentamos decodificar, si falla, usamos el cuerpo de la respuesta como texto plano.
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              'Credenciales inválidas o error desconocido.';
          throw Exception(errorMessage);
        } catch (e) {
          // Si no es JSON, el cuerpo de la respuesta es el error (ej. "Credenciales inválidas").
          throw Exception(response.body);
        }
      }
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor para iniciar sesión. Verifica tu conexión.',
      );
    } on FormatException {
      throw Exception(
        'Respuesta inesperada del servidor (formato JSON inválido).',
      );
    } catch (e) {
      // Limpiamos el mensaje de error para que sea más legible.
      throw Exception(
        'Error al iniciar sesión: ${e.toString().replaceFirst("Exception: ", "")}',
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

        // El backend devuelve { perfil: {...}, mensaje: ... }
        if (responseBody.containsKey('perfil')) {
          // SOLUCIÓN DE CONSISTENCIA:
          // Para unificar, devolvemos un mapa que usa la clave 'user',
          // igual que en el login/registro. Así, el resto de la app
          // siempre espera un 'user'.
          return {'user': responseBody['perfil']};
        } else {
          throw Exception(
            'La respuesta del servidor para el perfil no tiene el formato esperado (falta la clave "perfil").',
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
    } on SocketException {
      throw Exception(
        'No se pudo conectar con el servidor. Verifica tu conexión a internet.',
      );
    } catch (e) {
      throw Exception(
        'Ocurrió un error inesperado al obtener el perfil: ${e.toString()}',
      );
    }
  }

  // ==========================================================================
  // LÓGICA PARA ACTUALIZAR PERFIL DE USUARIO
  // ==========================================================================
  Future<Map<String, dynamic>> updateUserProfile({
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado para actualizar.');
    }

    final url = Uri.parse(
      '$_baseUrl$_profileEndpoint',
    ); // Mismo endpoint de perfil, pero con método PUT

    final body = jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
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

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // El backend devuelve { perfil: {...} }, lo envolvemos en { user: {...} } para consistencia.
        return {'user': responseBody['perfil']};
      } else {
        throw Exception('Fallo al actualizar el perfil: ${response.body}');
      }
    } catch (e) {
      throw Exception(
        'Error de conexión al actualizar el perfil: ${e.toString()}',
      );
    }
  }
}
