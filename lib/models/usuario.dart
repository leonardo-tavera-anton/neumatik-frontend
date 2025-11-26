// lib/models/usuario.dart

class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final bool esVendedor;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.esVendedor,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String,
      // Los roles de vendedor se suelen manejar con un booleano en el frontend
      esVendedor: json['esVendedor'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'apellido': apellido,
    'correo': correo,
    'telefono': telefono,
    'esVendedor': esVendedor,
  };
}
