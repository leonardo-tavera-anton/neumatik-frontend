// lib/screens/mis_publicaciones_screen.dart

import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/publicacion_service.dart';

class MisPublicacionesScreen extends StatefulWidget {
  const MisPublicacionesScreen({super.key});

  @override
  State<MisPublicacionesScreen> createState() => _MisPublicacionesScreenState();
}

class _MisPublicacionesScreenState extends State<MisPublicacionesScreen> {
  final PublicacionService _publicacionService = PublicacionService();
  late Future<List<PublicacionAutoparte>> _misPublicacionesFuture;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  // SOLUCIÓN: Función para (re)cargar los datos.
  Future<void> _reloadData() async {
    // Asigna el Future a la variable de estado para que el FutureBuilder se reconstruya.
    _misPublicacionesFuture = _publicacionService.getMisPublicaciones();
    setState(() {}); // Notifica al widget que debe reconstruirse.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Publicaciones'),
        backgroundColor: Colors.teal,
      ),
      // SOLUCIÓN: Envolvemos el cuerpo en un RefreshIndicator.
      body: RefreshIndicator(
        onRefresh: _reloadData, // Llama a la función de recarga al deslizar.
        color: Colors.teal,
        child: FutureBuilder<List<PublicacionAutoparte>>(
          future: _misPublicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final publicaciones = snapshot.data;

            if (publicaciones == null || publicaciones.isEmpty) {
              return const Center(
                child: Text('Aún no has creado ninguna publicación.'),
              );
            }

            return ListView.builder(
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final publicacion = publicaciones[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      publicacion
                          .fotoPrincipalUrl, // CORRECCIÓN: El campo se llama fotoPrincipalUrl
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(publicacion.nombreParte),
                    subtitle: Text(
                      'S/ ${publicacion.precio.toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Al tocar, navega a la pantalla de detalle.
                      // Desde allí se podrá editar.
                      Navigator.pushNamed(
                        context,
                        '/publicacion',
                        arguments: publicacion
                            .publicacionId, // CORRECCIÓN: El campo se llama publicacionId
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
