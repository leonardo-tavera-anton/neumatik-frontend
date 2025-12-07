// lib/screens/pago_exitoso_screen.dart
import 'package:flutter/material.dart';
import '../models/pedido.dart'; // Importamos el modelo Pedido

class PagoExitosoScreen extends StatelessWidget {
  const PagoExitosoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el objeto Pedido pasado como argumento desde la pantalla del carrito.
    final Pedido pedido;
    try {
      pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    } catch (e) {
      // Fallback por si se llega a esta pantalla sin un pedido.
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se pudo cargar la información del pedido.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra Exitosa'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // Oculta el botón de "atrás"
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.teal,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Gracias por tu compra!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Tu pedido ha sido procesado exitosamente.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'ID de tu pedido: ${pedido.id}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de inicio y elimina todas las rutas anteriores.
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                ),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
