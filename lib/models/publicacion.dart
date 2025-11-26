import 'foto_publicacion.dart';

class Publicacion {
  final String publicacionId;
  final String nombreParte;
  final String descripcionCorta;
  final double precio;
  final String fotoPrincipalUrl;
  final String condicion;
  final String ubicacionCiudad;
  final String vendedorId;
  final List<FotoPublicacion> fotos;

  Publicacion({
    required this.publicacionId,
    required this.nombreParte,
    required this.descripcionCorta,
    required this.precio,
    required this.fotoPrincipalUrl,
    required this.condicion,
    required this.ubicacionCiudad,
    required this.vendedorId,
    this.fotos = const [],
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    // Manejo de la lista de fotos si viene en el JSON
    final List<dynamic>? fotosJson = json['fotos'] as List<dynamic>?;
    final List<FotoPublicacion> fotosList = fotosJson != null
        ? fotosJson
              .map((f) => FotoPublicacion.fromJson(f as Map<String, dynamic>))
              .toList()
        : [];

    return Publicacion(
      publicacionId: json['id'] as String,
      // Asume que la API devuelve el nombre del producto o usa un default
      nombreParte: json['nombre_parte'] as String? ?? 'Autoparte',
      descripcionCorta:
          json['descripcion_corta'] as String? ?? 'Sin descripción.',
      // Conversión segura de precio (String/Num -> double)
      precio: double.parse(json['precio'].toString()),
      fotoPrincipalUrl:
          json['foto_principal_url'] as String? ??
          'https://via.placeholder.com/150',
      condicion: json['condicion'] as String? ?? 'Desconocida',
      ubicacionCiudad: json['ubicacion_ciudad'] as String? ?? 'N/A',
      vendedorId: json['id_vendedor'] as String,
      fotos: fotosList,
    );
  }
}
