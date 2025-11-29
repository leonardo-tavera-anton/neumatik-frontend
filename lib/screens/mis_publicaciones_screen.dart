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

  // SOLUCIÓN: Función para mostrar el diálogo de confirmación y eliminar.
  Future<void> _confirmarYEliminar(
    String publicacionId,
    String nombreParte,
  ) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // SOLUCIÓN: Se estiliza el AlertDialog para una mejor UX.
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Confirmar Eliminación'),
            ],
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la publicación "$nombreParte"? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            // Botón para cancelar la acción.
            OutlinedButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            // Botón principal para confirmar la eliminación.
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await _publicacionService.deletePublicacion(publicacionId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Publicación eliminada con éxito.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _reloadData(); // Recarga la lista para que desaparezca el elemento.
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                    // SOLUCIÓN: Añadimos un botón de eliminar.
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Eliminar Publicación',
                      onPressed: () => _confirmarYEliminar(
                        publicacion.publicacionId,
                        publicacion.nombreParte,
                      ),
                    ),
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
