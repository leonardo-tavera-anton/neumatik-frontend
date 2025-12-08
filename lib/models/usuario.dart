// lib/models/usuario.dart

class Usuario {
  final String id; //para poder llamar luego cambio d valor
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono, //ahora el db acepta nulos
  });

  String get nombreCompleto => '$nombre ${apellido ?? ''}'
      .trim(); //no es codigo muerto necesario para evitar errores

  //este factory necesario para crear una instancia del usuario (del mapa json)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    //manejo seguro d valores en los endpoints en backen, ya sea que venga como string o int del backend.
    final rawId = json['id'] ?? json['user_id'];
    final idString = rawId != null ? rawId.toString() : '';

    return Usuario(
      id: idString,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      correo: json['correo'] as String,
      telefono:
          json['telefono']
              as String?, //se permite que sea nulo si no viene del json o viene como null
    );
  }

  //mapa metodo para enviar datos al backend(en registro y actualización)
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'correo': correo,
    'telefono': telefono ?? '', //la db ahora tiene un "default""
  };
}
