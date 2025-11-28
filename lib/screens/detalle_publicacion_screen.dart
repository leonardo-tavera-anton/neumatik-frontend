import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart';
import '../services/publicacion_service.dart';

// RUTA ASIGNADA: '/publicacion' (Ruta dinámica)
// FUNCIÓN: Muestra la información detallada de una publicación específica.
class DetallePublicacionScreen extends StatefulWidget {
  // Recibe el ID de la publicación desde los argumentos de la ruta.
  final String publicacionId;

  const DetallePublicacionScreen({super.key, required this.publicacionId});

  @override
  State<DetallePublicacionScreen> createState() =>
      _DetallePublicacionScreenState();
}

class _DetallePublicacionScreenState extends State<DetallePublicacionScreen> {
  final PublicacionService _publicacionService = PublicacionService();
  final CarritoService _carritoService =
      CarritoService(); // CAMBIO: Se añade el servicio de carrito.
  late Future<PublicacionAutoparte> _publicacionFuture;

  @override
  void initState() {
    super.initState();
    // Llamamos al nuevo método para obtener los detalles de la publicación.
    _publicacionFuture = _publicacionService.getPublicacionById(
      widget.publicacionId,
    );
  }

  // SOLUCIÓN: Se añade la función que faltaba para manejar la acción de añadir al carrito.
  void _anadirAlCarrito(PublicacionAutoparte publicacion) async {
    try {
      await _carritoService.anadirAlCarrito(publicacion);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Producto añadido al carrito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir al carrito: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Autoparte')),
      // Usamos un FutureBuilder para manejar los estados de carga, error y éxito.
      body: FutureBuilder<PublicacionAutoparte>(
        future: _publicacionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró la publicación.'));
          }

          // Si todo sale bien, tenemos los datos de la publicación.
          final publicacion = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen principal
                Image.network(
                  publicacion.fotoPrincipalUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.car_crash,
                      color: Colors.grey,
                      size: 60,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y Verificación IA
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              publicacion.nombreParte,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (publicacion.iaVerificado)
                            const Tooltip(
                              message: 'Verificado por IA',
                              child: Icon(Icons.verified, color: Colors.blue),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Precio
                      Text(
                        '\$${publicacion.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Condición y Stock
                      Row(
                        children: [
                          Chip(
                            label: Text(publicacion.condicion),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          const SizedBox(width: 10),
                          Text('Stock disponible: ${publicacion.stock}'),
                        ],
                      ),
                      const Divider(height: 32),

                      // CAMBIO: Sección de Descripción
                      if (publicacion.descripcionCorta != null &&
                          publicacion.descripcionCorta!.isNotEmpty) ...[
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(publicacion.descripcionCorta!),
                        const Divider(height: 32),
                      ],

                      // Vendedor y Ubicación
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.storefront_outlined,
                          color: Colors.teal,
                        ),
                        title: const Text('Vendido por'),
                        subtitle: Text(publicacion.vendedorNombreCompleto),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.teal,
                        ),
                        title: const Text('Ubicación'),
                        subtitle: Text(publicacion.ubicacionCiudad),
                      ),
                      const SizedBox(height: 24),
                      // Botón de Añadir al Carrito
                      ElevatedButton.icon(
                        onPressed: () => _anadirAlCarrito(publicacion),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Añadir al Carrito'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
