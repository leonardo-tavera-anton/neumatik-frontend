import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/publicacion_autoparte.dart';

class CarritoService {
  static const _key = 'carrito';

  // Añade un producto al carrito.
  // Usamos un Map para evitar duplicados, usando el ID de la publicación como clave.
  Future<void> anadirAlCarrito(PublicacionAutoparte publicacion) async {
    final prefs = await SharedPreferences.getInstance();
    final carritoActual = await obtenerCarrito();

    // La clave es el ID, el valor es el objeto completo de la publicación.
    // Esto permite actualizar un producto si ya existe o añadirlo si es nuevo.
    carritoActual[publicacion.publicacionId] = publicacion;

    // Convertimos cada objeto PublicacionAutoparte a un mapa JSON.
    final Map<String, dynamic> carritoJson = carritoActual.map(
      (key, value) =>
          MapEntry(key, value.toJson()), // Asume que tienes un método toJson()
    );

    await prefs.setString(_key, json.encode(carritoJson));
  }

  // Obtiene todos los productos del carrito.
  Future<Map<String, PublicacionAutoparte>> obtenerCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final carritoString = prefs.getString(_key);

    if (carritoString == null) {
      return {};
    }

    final Map<String, dynamic> carritoJson = json.decode(carritoString);

    // Convertimos de vuelta de JSON a objetos PublicacionAutoparte.
    return carritoJson.map(
      (key, value) => MapEntry(key, PublicacionAutoparte.fromJson(value)),
    );
  }

  // Limpia todo el carrito.
  Future<void> limpiarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
