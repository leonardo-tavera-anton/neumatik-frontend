// lib/models/pedido.dart
import 'package:intl/intl.dart';

class Pedido {
  final String id;
  final String fecha;
  final double total;
  final String usuarioNombre;
  final String usuarioCorreo;
  final String estado;
  final Map<String, dynamic> direccionEnvio;
  final List<ItemPedido> items;

  Pedido({
    required this.id,
    required this.fecha,
    required this.total,
    required this.usuarioNombre,
    required this.usuarioCorreo,
    required this.estado,
    required this.direccionEnvio,
    required this.items,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    //la lista de items y si en el endpoint json no hay items como al crear pedi2 se muestra solo lista vacia
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final List<ItemPedido> items = itemsList
        .map((i) => ItemPedido.fromJson(i))
        .toList();

    //modo d manejo seguro para las fechas
    String formattedDate;
    try {
      //parseando la fecha que viene del backend en formato ISO 8601 AA/MM/DD HH:MM:SS y asi el resto
      final fechaOriginal = DateTime.parse(
        json['fecha'] as String,
      ); //y esto muestra a un formato mas legible para el usuario.
      formattedDate = DateFormat(
        'dd/MM/yyyy hh:mm a',
      ).format(fechaOriginal); //valor formateado a la variable.
    } catch (e) {
      //un trycath para q no crashee el app
      formattedDate = 'Fecha inválida';
    }

    return Pedido(
      id: json['id'].toString(),
      fecha: formattedDate,
      total:
          double.tryParse(json['total']?.toString() ?? '0.0') ??
          0.0, //tryParse para evitar errores si el valor no es un numero
      //valores por defecto si el campo no existe en el JSON.
      usuarioNombre: json['usuario_nombre'] as String? ?? 'N/A',
      usuarioCorreo: json['usuario_correo'] as String? ?? 'N/A',
      estado:
          json['estado_orden'] as String? ??
          'Pendiente', //parseando ando el estado del pedido con un fallback a "Pendiente"
      direccionEnvio:
          json['direccion_envio'] as Map<String, dynamic>? ??
          {}, //y tmb fallback si no existe direccion_envio
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
      nombre:
          json['nombre_parte'] as String? ??
          'Producto sin nombre', //valor por defecto si el campo no existe.
      //tryParse para evitar errores con valores no numericos en cantidad y precio
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      precio: double.tryParse(json['precio']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}
