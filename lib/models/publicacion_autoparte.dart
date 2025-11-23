// Archivo: lib/models/publicacion_autoparte.dart
//Este modelo está diseñado para mapear exactamente la respuesta JSON que genera el endpoint

class PublicacionAutoparte {
  final String publicacionId; // UUID de la publicación
  final String nombreParte; // Nombre del producto (e.j., 'Pastillas de freno')
  final String categoria; // Nombre de la categoría (e.j., 'Frenos')
  final String? numeroOem; // Número de parte del fabricante (puede ser nulo)
  final double precio;
  final String condicion; // Nuevo, Usado, Reacondicionado
  final int stock;
  final String ubicacionCiudad;
  final String vendedorNombreCompleto;
  final String fotoPrincipalUrl;
  final DateTime fechaPublicacion;
  final bool iaVerificado; // Campo del análisis IA

  PublicacionAutoparte({
    required this.publicacionId,
    required this.nombreParte,
    required this.categoria,
    this.numeroOem,
    required this.precio,
    required this.condicion,
    required this.stock,
    required this.ubicacionCiudad,
    required this.vendedorNombreCompleto,
    required this.fotoPrincipalUrl,
    required this.fechaPublicacion,
    required this.iaVerificado,
  });

  factory PublicacionAutoparte.fromJson(Map<String, dynamic> json) {
    // Concatenar nombre y apellido del vendedor
    final nombreCompleto =
        '${json['vendedor_nombre']} ${json['vendedor_apellido']}';

    // Manejo de la URL de la foto y conversión de tipos
    return PublicacionAutoparte(
      publicacionId: json['publicacion_id'] as String,
      nombreParte: json['nombre_parte'] as String,
      categoria: json['nombre_categoria'] as String,
      numeroOem: json['numero_oem'] as String?,
      precio: double.parse(json['precio'].toString()), //Convierte NUMERIC a String al fin funciona carajo
      condicion: json['condicion'] as String,
      stock: json['stock'] as int,
      ubicacionCiudad: json['ubicacion_ciudad'] as String,
      vendedorNombreCompleto: nombreCompleto,
      // Usamos un placeholder si la URL es nula o vacía
      fotoPrincipalUrl:
          json['foto_principal_url'] ??
          'https://via.placeholder.com/150?text=Neumatik',
      fechaPublicacion: DateTime.parse(
        json['fecha_publicacion'] as String,
      ), // Convierte TIMESTAMPTZ
      iaVerificado:
          json['ia_verificado'] as bool? ??
          false, // Maneja el nulo si el LEFT JOIN no encuentra IA
    );
  }
}
