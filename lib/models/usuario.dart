import 'dart:convert'; // Necesario para algunas utilidades de conversión si se expande la clase

// Modelo de datos para representar un Usuario (Vendedor o Comprador)
class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono; // Opcional (nullable)
  final bool esVendedor;
  final DateTime creadoEn;
  final DateTime? ultimaConexion; // Opcional (nullable)

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    required this.esVendedor,
    required this.creadoEn,
    this.ultimaConexion,
  });

  // Getter usado en la Snackbar y otros lugares
  String get nombreCompleto => '$nombre $apellido';

  // Factory constructor para crear un Usuario desde el JSON del backend
  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Las claves de JSON están adaptadas al snake_case que sugieres ('es_vendedor', 'creado_en')
    return Usuario(
      id:
          json['id'] as String? ??
          json['_id'] as String? ??
          '', // Acepta 'id' o '_id'
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
      telefono:
          json['telefono'] as String?, // String? maneja el null automáticamente
      esVendedor:
          json['es_vendedor'] as bool? ??
          false, // Clave corregida a 'es_vendedor'
      creadoEn: DateTime.parse(
        json['creado_en'] as String,
      ), // Clave corregida a 'creado_en'
      // Manejo opcional de la última conexión
      ultimaConexion: json['ultima_conexion'] != null
          ? DateTime.tryParse(json['ultima_conexion'] as String)
          : null,
    );
  }
}

// Clase que representa la respuesta completa de Login/Registro del servidor: Token + Usuario
class UsuarioAutenticado {
  final String token;
  final Usuario user; // Esta propiedad es la que estaba causando el error

  UsuarioAutenticado({required this.token, required this.user});

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) {
    return UsuarioAutenticado(
      token: json['token'] ?? '',
      // Asume que la información del usuario viene en una clave llamada 'user' o 'usuario'
      // Usamos el 'user' para coincidir con la variable en la clase de arriba.
      user: Usuario.fromJson(json['user'] ?? json['usuario']),
    );
  }
}
