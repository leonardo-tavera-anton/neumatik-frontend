// lib/services/pago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';
import '../models/publicacion_autoparte.dart';

class PedidoService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  //metodo para crear un nuevo pedido
  Future<Pedido> crearPedido({
    required List<PublicacionAutoparte> items,
    required double total,
    required Map<String, String> direccionEnvio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado para crear el pedido.');
    }

    //ajustamos la URL del endpoint
    final url = Uri.parse('$_baseUrl/api/pedidos');

    //preparamos los items para enviar al backend
    final itemsParaEnviar = items
        .map(
          (item) => {
            'id_publicacion': item.publicacionId,
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
        }, //headers
        body: jsonEncode({
          'items': itemsParaEnviar,
          'total': total,
          'direccion_envio': direccionEnvio,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Pedido.fromJson(responseData['pedido']);
      } else {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          try {
            final errorData = json.decode(response.body); //
            throw Exception(errorData['message'] ?? response.body);
          } catch (e) {
            throw Exception(
              'Error al procesar la respuesta del servidor: ${response.body}',
            );
          }
        } else {
          throw Exception(
            'Error del servidor (código ${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      throw Exception('Error de conexión al crear el pedido: ${e.toString()}');
    }
  }

  //metodo para obtener el historial de pedidos del usuario
  Future<List<Pedido>> getMisPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado para ver pedidos.');
    }

    //ajustamos la URL del endpoint
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
