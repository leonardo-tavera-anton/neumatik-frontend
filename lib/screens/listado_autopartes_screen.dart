// Archivo: lib/screens/lista_autopartes_screen.dart
//Pantalla que usará el modelo y el servicio para mostrar los datos en una lista.

import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/publicacion_autoparte.dart';

class ListadoAutopartesScreen extends StatelessWidget {
  final DataService apiService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neumatik: Autopartes en Venta'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: FutureBuilder<List<PublicacionAutoparte>>(
        future: apiService.getPublicacionesActivas(),
        builder: (context, snapshot) {
          // 1. Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error de conexión: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // 3. Datos Recibidos
          else if (snapshot.hasData) {
            final publicaciones = snapshot.data!;
            if (publicaciones.isEmpty) {
              return const Center(
                child: Text(
                  'No hay autopartes publicadas actualmente.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final p = publicaciones[index];
                return AutoparteCard(publicacion: p);
              },
            );
          }
          return const Center(child: Text('Esperando datos de la API...'));
        },
      ),
    );
  }
}

// Widget para el diseño de cada tarjeta de autoparte
class AutoparteCard extends StatelessWidget {
  final PublicacionAutoparte publicacion;

  const AutoparteCard({Key? key, required this.publicacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la autoparte
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                publicacion.fotoPrincipalUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Fallback si la imagen falla o es nula
                errorBuilder: (c, o, s) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.car_repair,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Detalles del texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Verificación IA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          publicacion.nombreParte,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (publicacion.iaVerificado)
                        Tooltip(
                          message: 'Verificado por IA',
                          child: Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    publicacion.categoria,
                    style: TextStyle(fontSize: 14, color: Colors.teal),
                  ),
                  const SizedBox(height: 8),
                  // Precio y Condición
                  Row(
                    children: [
                      Text(
                        '\$${publicacion.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          publicacion.condicion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: publicacion.condicion == 'Nuevo'
                            ? Colors.blue
                            : Colors.orange,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Ubicación y Vendedor
                  Text(
                    'Vendedor: ${publicacion.vendedorNombreCompleto} en ${publicacion.ubicacionCiudad}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
