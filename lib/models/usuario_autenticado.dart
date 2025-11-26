// lib/models/usuario_autenticado.dart

import 'usuario.dart'; // Importa el modelo Usuario

class UsuarioAutenticado {
  final String token;
  final Usuario user; // Contiene la información del usuario

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    return UsuarioAutenticado(
      token: json['token'] as String,
      // Se utiliza Usuario.fromJson() para deserializar el objeto anidado 'user'
      user: Usuario.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
