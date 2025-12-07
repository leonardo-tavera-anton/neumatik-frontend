// lib/models/pedido.dart
import 'package:intl/intl.dart';
// La importación de publicacion_autoparte no es estrictamente necesaria aquí,
// pero se deja por si se expande el modelo en el futuro.
import 'publicacion_autoparte.dart';

class Pedido {
  final String id;
  final String fecha;
  final double total;
  final String usuarioNombre;
  final String usuarioCorreo;
  final List<ItemPedido> items;

  Pedido({
    required this.id,
    required this.fecha,
    required this.total,
    required this.usuarioNombre,
    required this.usuarioCorreo,
    required this.items,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<ItemPedido> items = itemsList
        .map((i) => ItemPedido.fromJson(i))
        .toList();

    // --- MEJORA: Manejo seguro de la fecha ---
    String formattedDate;
    try {
      // Intenta parsear la fecha que viene del backend (usualmente en formato ISO 8601)
      final fechaOriginal = DateTime.parse(json['fecha'] as String);
      // Formatea la fecha a un formato más legible para el usuario.
    } catch (e) {
      // Si el parseo falla, asigna un valor por defecto para evitar que la app crashe.
      formattedDate = 'Fecha inválida';
    }

    return Pedido(
      id: json['id'].toString(),
      fecha: formattedDate,
      total: double.parse(json['total'].toString()),
      usuarioNombre: json['usuario_nombre'],
      usuarioCorreo: json['usuario_correo'],
      items: items,
    );
  }
}

// Modelo simple para los items dentro del pedido.
class ItemPedido {
  final String nombre;
  final int cantidad;
  final double precio;

  ItemPedido({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      nombre: json['nombre_parte'],
      cantidad: json['cantidad'],
      precio: double.parse(json['precio'].toString()),
    );
  }
}
