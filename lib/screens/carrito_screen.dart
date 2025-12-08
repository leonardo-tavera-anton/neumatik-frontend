// lib/screens/carrito_screen.dart
import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart';
import '../services/pago_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();
  final PedidoService _pedidoService = PedidoService();

  late Future<List<PublicacionAutoparte>> _carritoFuture;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadCarrito(); //inicial del carrito
  }

  void _loadCarrito() {
    setState(() {
      _carritoFuture = _carritoService.getCarrito();
    });
  }

  //irACheckou CAMBIO permite navegar a la pantalla de checkout.
  void _irACheckout(List<PublicacionAutoparte> items, double total) async {
    Navigator.of(
      context,
    ).pushNamed('/checkout', arguments: {'items': items, 'total': total});
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
              subtotal; //d aqui para abajo se le puede agregar mas datos, como costos d loli y asi

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
                      //precio unitario y subtotal del item.
                      subtitle: Text(
                        'S/ ${item.precio.toStringAsFixed(2)} c/u  (Total: S/ ${(item.precio * item.cantidadEnCarrito).toStringAsFixed(2)})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //boton d disminuir cantidad
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () async {
                              await _carritoService.decrementarCantidad(
                                item.publicacionId,
                              );
                              _loadCarrito(); //una vez hecho se recarga la ui
                            },
                          ),
                          //muestra la cantidad actual
                          Text(
                            item.cantidadEnCarrito.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          //bton para aumentar cantidad
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: Colors.teal,
                            onPressed: () async {
                              //condicional para validad stock disponible
                              if (item.cantidadEnCarrito < item.stock) {
                                await _carritoService.incrementarCantidad(
                                  item.publicacionId,
                                );
                                _loadCarrito(); //otra vez recargamos para q se muestre
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No hay más stock disponible.', //mensajuto en caso llegue al limite
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              //info y boton para pagar
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
                          : () => _irACheckout(items, total),
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
                      label: const Text('Continuar Compra'),
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
