// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/pago_service.dart';
import '../services/carrito_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<PublicacionAutoparte> items;
  final double total;

  const CheckoutScreen({super.key, required this.items, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final PedidoService _pedidoService = PedidoService();
  final CarritoService _carritoService = CarritoService();
  bool _isProcessingPayment = false;

  // Controladores para los campos del formulario
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _tarjetaController = TextEditingController();
  final _fechaExpController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _direccionController.dispose();
    _ciudadController.dispose();
    _referenciaController.dispose();
    _tarjetaController.dispose();
    _fechaExpController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _finalizarCompra() async {
    // Validamos que el formulario esté correcto
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessingPayment = true);

    // Creamos el objeto de dirección para enviar al backend
    final direccionEnvio = {
      "direccion": _direccionController.text,
      "ciudad": _ciudadController.text,
      "referencia": _referenciaController.text,
      "pais": "Perú",
    };

    try {
      // 1. Llamamos al servicio para crear el pedido
      final pedidoConfirmado = await _pedidoService.crearPedido(
        items: widget.items,
        total: widget.total,
        direccionEnvio: direccionEnvio,
      );

      // 2. Limpiamos el carrito localmente
      await _carritoService.limpiarCarrito();

      if (mounted) {
        // 3. Navegamos a la pantalla de éxito
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/pago-exitoso',
          (route) => false,
          arguments: pedidoConfirmado,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pedido: ${e.toString()}'),
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
        title: const Text('Finalizar Compra'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sección de Dirección de Envío ---
              const Text(
                'Dirección de Envío',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección (Ej: Av. La Marina 123)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'La dirección es obligatoria' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'La ciudad es obligatoria' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const Divider(height: 40),

              // --- Sección de Pago ---
              const Text(
                'Información de Pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Simulando ando, para ver si funciona :)',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarjetaController,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? 'El número de tarjeta es obligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fechaExpController,
                      decoration: const InputDecoration(
                        labelText: 'MM/AA',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Botón de Pagar ---
              ElevatedButton.icon(
                onPressed: _isProcessingPayment ? null : _finalizarCompra,
                icon: _isProcessingPayment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _isProcessingPayment
                      ? 'Procesando...'
                      : 'Pagar S/ ${widget.total.toStringAsFixed(2)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
