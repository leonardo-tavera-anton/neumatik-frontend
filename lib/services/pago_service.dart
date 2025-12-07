// lib/services/pago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/publicacion_autoparte.dart';

// MEJORA: Renombrar a PedidoService para mayor claridad.
class PedidoService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  // MEJORA: El método ahora acepta la lista de items del carrito y el total.
  Future<Pedido> crearPedido({
    required List<PublicacionAutoparte> items,
    required double total,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado para crear el pedido.');
    }

    // CORRECCIÓN: Apuntar al endpoint correcto en el backend.
    final url = Uri.parse('$_baseUrl/api/pedidos');

    // MEJORA: Construir la lista de items en el formato que el backend espera.
    final itemsParaEnviar = items
        .map(
          (item) => {
            'publicacionId':
                item.publicacionId, // CORRECCIÓN: El campo es publicacionId
            'cantidad': item.cantidadEnCarrito,
            'precio': item.precio,
          },
        )
        .toList();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        // CORRECCIÓN: Enviar el cuerpo completo que el backend espera.
        body: jsonEncode({'items': itemsParaEnviar, 'total': total}),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Pedido.fromJson(responseData['pedido']);
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Error al crear el pedido.');
        } catch (e) {
          throw Exception(
            'El servidor devolvió una respuesta inesperada (código ${response.statusCode}).',
          );
        }
      }
    } catch (e) {
      throw Exception('Error de conexión al crear el pedido: ${e.toString()}');
    }
  }

  // MEJORA: Añadir método para obtener el historial de pedidos del usuario.
  Future<List<Pedido>> getMisPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado para ver pedidos.');
    }

    // El endpoint es el mismo que para crear, pero con el método GET.
    final url = Uri.parse('$_baseUrl/api/pedidos');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pedido.fromJson(json)).toList();
    } else {
      throw Exception(
        'Fallo al cargar el historial de pedidos: ${response.body}',
      );
    }
  }
}
