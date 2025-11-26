import 'package:flutter/material.dart';

// Modelo de datos para representar un Usuario (Vendedor o Comprador)
class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final bool esVendedor;
  final DateTime creadoEn;
  final DateTime? ultimaConexion;

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

  String get nombreCompleto => '$nombre $apellido';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String?,
      esVendedor: json['es_vendedor'] as bool? ?? false,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      // Manejo opcional de la última conexión
      ultimaConexion: json['ultima_conexion'] != null
          ? DateTime.tryParse(json['ultima_conexion'] as String)
          : null,
    );
  }
}
