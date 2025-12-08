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

  //misma funcion para recargar datos
  Future<void> _reloadData() async {
    _misPublicacionesFuture = _publicacionService.getMisPublicaciones();
    setState(() {});
  }

  //funcion para mostrar la confirmación y eliminar sus dialogos
  Future<void> _confirmarYEliminar(
    String publicacionId,
    String nombreParte,
  ) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
            //boton d cancelar
            OutlinedButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            //boton para confirmar eliminacion
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
        _reloadData(); //recarga datos despues de eliminar
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
      //el refresh indicator para recargar al deslizar
      body: RefreshIndicator(
        onRefresh: _reloadData, //funcion para recargar
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
                      publicacion.fotoPrincipalUrl,
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
                    //boton eliminar
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Eliminar Publicación',
                      onPressed: () => _confirmarYEliminar(
                        publicacion.publicacionId,
                        publicacion.nombreParte,
                      ),
                    ),
                    onTap: () {
                      //navigar a la pantalla de detalle de publicacion
                      Navigator.pushNamed(
                        context,
                        '/publicacion',
                        arguments: publicacion.publicacionId,
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
