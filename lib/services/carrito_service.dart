import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/publicacion_autoparte.dart';

class CarritoService {
  static const _key = 'carrito';

  //añade un producto al carrito
  Future<void> anadirAlCarrito(PublicacionAutoparte publicacion) async {
    final prefs = await SharedPreferences.getInstance();
    final carritoMap = await obtenerCarrito();

    //verificamos si el producto ya está en el carrito
    if (carritoMap.containsKey(publicacion.publicacionId)) {
      //si ya existe incrementamos la cantidad
      carritoMap[publicacion.publicacionId]!.cantidadEnCarrito++;
    } else {
      //en caso contrario lo añadimos con cantidad 1
      publicacion.cantidadEnCarrito = 1;
      carritoMap[publicacion.publicacionId] = publicacion;
    }

    //guardamos el carrito actualizado
    final Map<String, dynamic> carritoJson = carritoMap.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await prefs.setString(_key, json.encode(carritoJson));
  }

  //obtiene el carrito completo como un mapa
  Future<Map<String, PublicacionAutoparte>> obtenerCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final carritoString = prefs.getString(_key);

    if (carritoString == null) {
      return {};
    }

    final Map<String, dynamic> carritoJson = json.decode(carritoString);

    //convertimos el mapa json a un mapa de PublicacionAutoparte
    return carritoJson.map(
      (key, value) => MapEntry(key, PublicacionAutoparte.fromJson(value)),
    );
  }

  //obtiene la lista de productos en el carrito
  Future<List<PublicacionAutoparte>> getCarrito() async {
    final carritoMap = await obtenerCarrito();
    return carritoMap.values.toList();
  }

  //calcula el subtotal del carrito
  double getSubtotal(List<PublicacionAutoparte> items) {
    return items.fold(
      0.0,
      (sum, item) => sum + (item.precio * item.cantidadEnCarrito),
    );
  }

  //elimina un producto del carrito por su id
  Future<void> eliminarDelCarrito(String publicacionId) async {
    final prefs = await SharedPreferences.getInstance();
    final carritoActual = await obtenerCarrito();

    carritoActual.remove(publicacionId);

    final Map<String, dynamic> carritoJson = carritoActual.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await prefs.setString(_key, json.encode(carritoJson));
  }

  //limpia todo el carrito
  Future<void> limpiarCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  //incrementa la cantidad de un producto en el carrito
  Future<void> incrementarCantidad(String publicacionId) async {
    final prefs = await SharedPreferences.getInstance();
    final carritoMap = await obtenerCarrito();

    if (carritoMap.containsKey(publicacionId)) {
      final item = carritoMap[publicacionId]!;
      //verifica que no se exceda el stock disponible
      if (item.cantidadEnCarrito < item.stock) {
        item.cantidadEnCarrito++;
        final Map<String, dynamic> carritoJson = carritoMap.map(
          (key, value) => MapEntry(key, value.toJson()),
        );
        await prefs.setString(_key, json.encode(carritoJson));
      }
    }
  }

  //decrementa la cantidad de un producto en el carrito
  Future<void> decrementarCantidad(String publicacionId) async {
    final prefs = await SharedPreferences.getInstance();
    final carritoMap = await obtenerCarrito();

    if (carritoMap.containsKey(publicacionId)) {
      final item = carritoMap[publicacionId]!;
      if (item.cantidadEnCarrito > 1) {
        item.cantidadEnCarrito--;
        final Map<String, dynamic> carritoJson = carritoMap.map(
          (key, value) => MapEntry(key, value.toJson()),
        );
        await prefs.setString(_key, json.encode(carritoJson));
      } else {
        //si la cantidad es 1 y se decrementa se elimina el producto del carrito esto evita cantidades negativas y simula el d temu
        await eliminarDelCarrito(publicacionId);
      }
    }
  }
}
