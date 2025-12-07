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
      // CORRECCIÓN: Se asigna el valor formateado a la variable.
      formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(fechaOriginal);
    } catch (e) {
      // Si el parseo falla, asigna un valor por defecto para evitar que la app crashe.
      formattedDate = 'Fecha inválida';
    }

    return Pedido(
      id: json['id'].toString(),
      fecha: formattedDate,
      // MEJORA: Usar tryParse para evitar errores si el valor no es un número.
      total: double.tryParse(json['total']?.toString() ?? '0.0') ?? 0.0,
      // CORRECCIÓN: Asignar un valor por defecto si el campo no existe en el JSON.
      usuarioNombre: json['usuario_nombre'] as String? ?? 'N/A',
      usuarioCorreo: json['usuario_correo'] as String? ?? 'N/A',
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
      // MEJORA: Asignar un valor por defecto si el campo no existe.
      nombre: json['nombre_parte'] as String? ?? 'Producto sin nombre',
      // MEJORA: Usar tryParse para evitar errores con valores no numéricos.
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      precio: double.tryParse(json['precio']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
