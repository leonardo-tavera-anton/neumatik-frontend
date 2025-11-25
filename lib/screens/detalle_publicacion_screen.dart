import 'package:flutter/material.dart';

// RUTA ASIGNADA: '/publicacion' (Ruta dinámica)
// FUNCIÓN: Muestra la información detallada de una publicación específica.
class DetallePublicacionScreen extends StatelessWidget {
  // Recibe el ID de la ruta para buscar en la tabla 'publicaciones'
  final String? publicacionId;

  const DetallePublicacionScreen({super.key, this.publicacionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Autoparte'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Detalle de Producto',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí se mostrará toda la información. ID de la publicación: ${publicacionId ?? "N/A"}. Datos de reviews, fotos y compatibilidad (compatibilidad_producto).',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
