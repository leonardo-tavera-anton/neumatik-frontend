// lib/models/usuario_autenticado.dart

import 'usuario.dart';

class UsuarioAutenticado {
  //contenemos el usuario y el token
  final String token;
  final Usuario user;

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    if (json['usuario'] == null || json['usuario'] is! Map<String, dynamic>) {
      //error controlado si es null o no es un mapa valido
      throw const FormatException(
        'La respuesta del servidor no contiene un objeto de usuario válido.',
      );
    }

    return UsuarioAutenticado(
      token: json['token'] as String, //toString
      //ya validado
      user: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
