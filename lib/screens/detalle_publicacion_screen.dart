import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/carrito_service.dart';
import '../services/publicacion_service.dart';
import '../services/auth_service.dart';

//ruta: "/publicacion"
class DetallePublicacionScreen extends StatefulWidget {
  final String publicacionId;

  const DetallePublicacionScreen({super.key, required this.publicacionId});

  @override
  State<DetallePublicacionScreen> createState() =>
      _DetallePublicacionScreenState();
}

class _DetallePublicacionScreenState extends State<DetallePublicacionScreen> {
  final PublicacionService _publicacionService = PublicacionService();
  final CarritoService _carritoService = CarritoService();
  final AuthService _authService = AuthService(); //verificar el dueño

  late Future<PublicacionAutoparte> _publicacionFuture;
  @override
  void initState() {
    super.initState();
    _cargarDatosYVerificarPropietario();
  }

  bool _esPropietario = false; //estado para saber si el usuario es el dueño.
  Future<void> _cargarDatosYVerificarPropietario() async {
    final future = _publicacionService.getPublicacionById(widget.publicacionId);
    setState(() {
      _publicacionFuture = future;
    });

    try {
      final currentUserId = await _authService.getCurrentUserId();
      final publicacion = await future;

      if (mounted &&
          currentUserId != null &&
          currentUserId.toString() == publicacion.idVendedor) {
        //Comparacion d ambos ids como strings.
        setState(() {
          _esPropietario = true;
        });
      }
    } catch (e) {
      //otro manejo d error aunque el futurebuilder ya lo hace.
    }
  }

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
    //futurebuilder ahora envuelve todo el scaffold
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

        //se deberia tener los datos de la publicación.
        final publicacion = snapshot.data!;

        //el Scaffold es para tener los datos.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Autoparte'),
            actions: [
              if (_esPropietario)
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Editar Publicación',
                  onPressed: () {
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
                //imagen principal
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
                      //nombre y verificacion d IA
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
                      //eel resto del código sigue igual
                      const SizedBox(height: 8),
                      Text(
                        'S/ ${publicacion.precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

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

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.category_outlined,
                          color: Colors.teal,
                        ),
                        title: const Text('Categoría'),
                        subtitle: Text(publicacion.categoria),
                      ),

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
                      //boton para añadir al carrito solo si el usuario NOOOO es el propietario.
                      if (!_esPropietario)
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
