// lib/models/usuario_autenticado.dart

import 'usuario.dart'; // Importa el modelo Usuario

class UsuarioAutenticado {
  final String token;
  final Usuario user; // Contiene la información del usuario

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    // SOLUCIÓN: Validar que el objeto 'user' exista en la respuesta JSON.
    // Si 'user' es nulo o no es un mapa, se lanza un error controlado.
    if (json['user'] == null || json['user'] is! Map<String, dynamic>) {
      throw const FormatException(
        'La respuesta del servidor no contiene un objeto de usuario válido.',
      );
    }

    return UsuarioAutenticado(
      token: json['token'] as String,
      // Se utiliza Usuario.fromJson() para deserializar el objeto anidado 'user'
      // Ahora es seguro hacer el cast porque ya lo validamos arriba.
      user: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
