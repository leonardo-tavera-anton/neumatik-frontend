// lib/models/usuario.dart

class Usuario {
  // Se cambia a String, siguiendo el modelo proporcionado, pero
  // se utiliza la lógica robusta para manejar la deserialización.
  final String id;
  final String nombre;
  // CRÍTICO: Se hace REQUIRED aquí para evitar errores 500, ya que PostgreSQL
  // tiene este campo como NOT NULL.
  final String apellido;
  final String correo;
  final String? telefono;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido, // Vuelve a ser requerido
    required this.correo,
    this.telefono, // Sigue siendo opcional (acepta NULL en DB)
  });

  String get nombreCompleto =>
      '$nombre ${apellido ?? ''}'.trim(); //no es codigo muerto

  // Factory para crear una instancia de Usuario a partir de un mapa JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Maneja 'id' o 'user_id' y asegura que sea un String,
    // ya sea que venga como String o int del backend.
    final rawId = json['id'] ?? json['user_id'];
    final idString = rawId != null ? rawId.toString() : '';

    return Usuario(
      id: idString,
      nombre: json['nombre'] as String,
      // Al deserializar, asumimos que el backend siempre devuelve un apellido no nulo
      // debido a la restricción NOT NULL en la base de datos.
      apellido: json['apellido'] as String,
      correo: json['correo'] as String,
      // Se permite que sea nulo si no viene del JSON o viene como null
      telefono: json['telefono'] as String?,
    );
  }

  // Método para enviar datos al backend (útil en el registro o actualización)
  Map<String, dynamic> toJson() => {
    // 'id' no suele enviarse en el registro
    'nombre': nombre,
    'apellido': apellido, // Aseguramos que el campo se envíe
    'correo': correo,
    // SIMPLIFICACIÓN: Enviamos el valor directamente. La DB ahora tiene un DEFAULT.
    'telefono': telefono ?? '',
  };
}
