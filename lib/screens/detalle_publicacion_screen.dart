import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart';
import '../services/publicacion_service.dart';
import '../services/auth_service.dart'; // Importamos para saber quién es el usuario.

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
  final AuthService _authService =
      AuthService(); // SOLUCIÓN: Para verificar el dueño.

  late Future<PublicacionAutoparte> _publicacionFuture;
  bool _esPropietario = false; // Estado para saber si el usuario es el dueño.

  @override
  void initState() {
    super.initState();
    _cargarDatosYVerificarPropietario();
  }

  // SOLUCIÓN: Nueva función para cargar todo y verificar si el usuario es el dueño.
  Future<void> _cargarDatosYVerificarPropietario() async {
    // Iniciamos la carga de la publicación.
    final future = _publicacionService.getPublicacionById(widget.publicacionId);
    setState(() {
      _publicacionFuture = future;
    });

    try {
      // Obtenemos el ID del usuario actual y los datos de la publicación.
      final currentUserId = await _authService.getCurrentUserId();
      final publicacion = await future;

      if (mounted &&
          currentUserId != null &&
          currentUserId.toString() == publicacion.idVendedor) {
        // CORRECCIÓN: Comparamos ambos IDs como Strings.
        setState(() {
          _esPropietario = true;
        });
      }
    } catch (e) {
      // Manejar error si es necesario, aunque el FutureBuilder ya lo hace.
    }
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
    // CORRECCIÓN: El FutureBuilder ahora envuelve todo el Scaffold.
    return FutureBuilder<PublicacionAutoparte>(
      future: _publicacionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.teal)),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text(
                'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('No Encontrado')),
            body: Center(child: Text('No se encontró la publicación.')),
          );
        }

        // Si todo sale bien, tenemos los datos de la publicación.
        final publicacion = snapshot.data!;

        // Construimos el Scaffold completo ahora que tenemos los datos.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Autoparte'),
            actions: [
              if (_esPropietario)
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Editar Publicación',
                  onPressed: () {
                    // CORRECCIÓN: Ahora 'snapshot' sí está definido en este contexto.
                    Navigator.pushNamed(
                      context,
                      '/edit-publicacion',
                      arguments: snapshot.data!,
                    );
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
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
                // Resto del contenido de la pantalla...
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
                      // ... (el resto del código sigue igual)
                      const SizedBox(height: 8),
                      // Precio
                      Text(
                        'S/ ${publicacion.precio.toStringAsFixed(2)}',
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
          ),
        );
      },
    );
  }
}
