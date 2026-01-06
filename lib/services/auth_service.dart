// lib/services/auth_service.dart

import 'dart:convert';
import 'dart:io'; // esta importacio es necesaria para Socket Exception (para manejo d red)
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario_autenticado.dart';

class AuthService {
  static const String _baseUrl =
      'https://neumatik-backend.up.railway.app'; //URL base del backend
  static const String _tokenKey = 'auth_token';

  //los endpoints
  final String _loginEndpoint = '/api/auth/login';
  final String _registerEndpoint = '/api/registro';
  final String _profileEndpoint =
      '/api/usuario/perfil'; //endpoint para obtener y actualizar perfil

  //PERSISTENCIAS (SharedPreferences) estos metodos privados
  //logica para guardar, obtener y eliminar el token JWT

  //guarda el token en el almacenamiento local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  //obtiene el token del almacenamiento local
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  //elimina el token del almacenamiento local (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  //verifica si el usuario está logueado
  Future<bool> isUserLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }

  //obtiene el id del usuario actual desde el token JWT
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

  //===================
  //logica de registro
  Future<UsuarioAutenticado> registerUser({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    final url = Uri.parse('$_baseUrl$_registerEndpoint');

    final body = jsonEncode({
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena, //la contraseña se envía tal cual al backend
      'telefono': telefono,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // 1. Registro exitoso (201 en el railway se verifica esto debe estar en verde no olvidar)
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        //parsea la respuesta en el modelo UsuarioAutenticado
        final authResult = UsuarioAutenticado.fromJson(responseBody);

        await _saveToken(authResult.token);

        return authResult;
      } else {
        // 2. Manejo de errores (400, 409, 500, 505 etc etc)
        if (response.body.isEmpty) {
          throw Exception(
            'Error en el registro. El servidor respondió con un error pero sin detalles (Código: ${response.statusCode})',
          );
        }

        //trycatch para decodificar y si falla usamos el cuerpo de la respuesta como texto plano.
        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              errorBody['error'] ??
              'Ocurrió un error desconocido.';
          throw Exception(errorMessage);
        } catch (e) {
          //ya ahora si no es json la info el cuerpo de la respuesta es el error en caso solo para descartar
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

  //================
  //logica de login
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
        // Login exitoso
        try {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          final authResult = UsuarioAutenticado.fromJson(responseBody);

          await _saveToken(authResult.token);

          return authResult;
        } catch (e) {
          throw Exception(
            'El servidor dio una respuesta inesperada. Cuerpo: ${response.body}',
          );
        }
      } else {
        if (response.body.isEmpty) {
          throw Exception(
            'Credenciales inválidas o error del servidor (Código: ${response.statusCode})',
          );
        }

        try {
          final Map<String, dynamic> errorBody = jsonDecode(response.body);
          final errorMessage =
              errorBody['message'] ??
              errorBody['detail'] ??
              'Credenciales inválidas o error desconocido.';
          throw Exception(errorMessage);
        } catch (e) {
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
      //otros errores
      throw Exception(
        'Error al iniciar sesión: ${e.toString().replaceFirst("Exception: ", "")}',
      );
    }
  }

  //logica para obtener el perfil de usuario
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
          'Authorization': 'Bearer $token', //envia el token en el header
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody.containsKey('perfil')) {
          //verifica que la clave exista
          return {'user': responseBody['perfil']};
        } else {
          throw Exception(
            'La respuesta del servidor para el perfil no tiene el formato esperado (falta la clave "perfil").',
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        //token invalido o expirado
        await logout();
        throw Exception(
          'Sesión expirada o token inválido. Vuelva a iniciar sesión.',
        );
      } else {
        //otros errores del servidor (ej. 500)
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

  //logica para actualizar el perfil de usuario
  Future<Map<String, dynamic>> updateUserProfile({
    required String nombre,
    required String apellido,
    required String telefono,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Usuario no autenticado para actualizar.');
    }
    //endpoint
    final url = Uri.parse('$_baseUrl$_profileEndpoint');

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
        //retorna el perfil actualizado
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
