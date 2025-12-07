// lib/screens/carrito_screen.dart
import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart'; // La importación ahora funcionará
import '../services/pago_service.dart'; // CORRECCIÓN: El nombre del archivo y la clase ahora es PedidoService

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();
  // CORRECCIÓN: Usamos el nuevo nombre del servicio.
  final PedidoService _pedidoService = PedidoService();

  late Future<List<PublicacionAutoparte>> _carritoFuture;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadCarrito(); // Carga inicial del carrito
  }

  void _loadCarrito() {
    setState(() {
      _carritoFuture = _carritoService.getCarrito();
    });
  }

  // MEJORA: El método ahora recibe la lista de items para enviarla al backend.
  Future<void> _procesarPago(
    List<PublicacionAutoparte> items,
    double total,
  ) async {
    if (total <= 0) return;

    setState(() => _isProcessingPayment = true);

    try {
      // 1. Llamamos al servicio para crear el pedido, pasando los items y el total.
      final pedidoConfirmado = await _pedidoService.crearPedido(
        items: items,
        total: total,
      );

      // 2. Limpiamos el carrito localmente
      await _carritoService.limpiarCarrito();

      if (mounted) {
        // 3. Navegamos a la pantalla de éxito, pasando el objeto 'pedido'
        Navigator.of(
          context,
        ).pushReplacementNamed('/pago-exitoso', arguments: pedidoConfirmado);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el pago: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito de Compras'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<PublicacionAutoparte>>(
        future: _carritoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tu carrito está vacío.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final items = snapshot.data!;
          final double subtotal = _carritoService.getSubtotal(items);
          final double total =
              subtotal; // Aquí podrías añadir costos de envío, etc.

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
                      subtitle: Text('S/ ${item.precio.toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_shopping_cart,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await _carritoService.eliminarDelCarrito(
                            item.publicacionId,
                          );
                          _loadCarrito(); // Recargamos la lista
                        },
                      ),
                    );
                  },
                ),
              ),
              // --- Resumen y Botón de Pago ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 18)),
                        Text(
                          'S/ ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'S/ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: (_isProcessingPayment || total == 0)
                          ? null
                          : () => _procesarPago(items, total),
                      icon: _isProcessingPayment
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.payment),
                      label: Text(
                        _isProcessingPayment ? 'Procesando...' : 'Pagar Ahora',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
