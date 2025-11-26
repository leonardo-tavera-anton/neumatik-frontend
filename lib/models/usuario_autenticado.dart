// lib/models/usuario_autenticado.dart

import 'dart:convert';
// Importa el modelo Usuario si decides crear uno más completo
// import 'usuario.dart';

class UsuarioAutenticado {
  // El token que usarás para todas las peticiones futuras (seguridad)
  final String token;

  // Asumiendo que el backend devuelve un ID, nombre y correo del usuario
  final String id;
  final String nombre;
  final String correo;

  // Puedes añadir otros campos esenciales si los devuelve el backend
  // final bool esVendedor;

  UsuarioAutenticado({
    required this.token,
    required this.id,
    required this.nombre,
    required this.correo,
    // this.esVendedor = false,
  });

  // Constructor desde JSON
  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    // Nota: Los nombres de las claves (e.g., 'access_token', 'user_id')
    // deben coincidir exactamente con lo que devuelve tu API.
    return UsuarioAutenticado(
      token: json['access_token'] as String,
      id:
          json['user_id']
              as String, // Ajusta el nombre de la clave si es diferente
      nombre:
          json['user_name']
              as String, // Ajusta el nombre de la clave si es diferente
      correo:
          json['user_email']
              as String, // Ajusta el nombre de la clave si es diferente
      // esVendedor: json['es_vendedor'] as bool? ?? false,
    );
  }

  // Método para convertir a JSON (útil para guardar en almacenamiento local)
  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'user_id': id,
      'user_name': nombre,
      'user_email': correo,
      // 'es_vendedor': esVendedor,
    };
  }
}
