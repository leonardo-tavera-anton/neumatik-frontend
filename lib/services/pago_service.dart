// lib/services/pago_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';

class PagoService {
  static const String _baseUrl = 'https://neumatik-backend.up.railway.app';

  Future<Pedido> procesarPago(double total) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Usuario no autenticado para procesar el pago.');
    }

    // Este endpoint debería existir en tu backend.
    // Debería procesar el carrito, crear un pedido en la DB y enviar el correo.
    final url = Uri.parse('$_baseUrl/api/pagos/procesar');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'total': total}),
      );

      if (response.statusCode == 201) {
        // El backend debería devolver los detalles del pedido creado.
        final responseData = json.decode(response.body);
        return Pedido.fromJson(responseData['pedido']);
      } else {
        // Manejar errores del backend
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Error al procesar el pago.');
        } catch (e) {
          throw Exception(
            'El servidor devolvió una respuesta inesperada (código ${response.statusCode}).',
          );
        }
      }
    } catch (e) {
      throw Exception('Error de conexión al procesar el pago: ${e.toString()}');
    }
  }
}
