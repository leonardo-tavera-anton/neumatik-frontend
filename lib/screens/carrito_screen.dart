import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart';

// RUTA ASIGNADA: '/carrito'
// FUNCIÓN: Muestra los productos añadidos al carrito y el total.
class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();
  late Future<Map<String, PublicacionAutoparte>> _carritoFuture;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
  }

  void _cargarCarrito() {
    setState(() {
      _carritoFuture = _carritoService.obtenerCarrito();
    });
  }

  void _limpiarCarrito() async {
    await _carritoService.limpiarCarrito();
    _cargarCarrito(); // Recarga la pantalla para mostrar el carrito vacío.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _limpiarCarrito,
            tooltip: 'Limpiar Carrito',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, PublicacionAutoparte>>(
        future: _carritoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tu Carrito está Vacío',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data!.values.toList();
          final double total = items.fold(
            0.0,
            (sum, item) => sum + item.precio,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Image.network(
                        item.fotoPrincipalUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item.nombreParte),
                      subtitle: Text(item.condicion),
                      trailing: Text(
                        '\$${item.precio.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              // Resumen y botón de pago
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 20)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        /* Lógica para proceder al pago */
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      // SOLUCIÓN: Se añade el 'child' que faltaba para el botón.
                      child: const Text(
                        'Proceder al Pago',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
