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
    //llamado d la lista dsd el json
    final List<dynamic>? fotosJson = json['fotos'] as List<dynamic>?;
    final List<FotoPublicacion> fotosList = fotosJson != null
        ? fotosJson
              .map((f) => FotoPublicacion.fromJson(f as Map<String, dynamic>))
              .toList()
        : [];

    return Publicacion(
      publicacionId: json['id'] as String,

      nombreParte:
          json['nombre_parte'] as String? ??
          'Autoparte', //espera q el api devuelve el nombre del producto o un valor por defecto
      descripcionCorta:
          json['descripcion_corta'] as String? ?? 'Sin descripción.',
      precio: double.parse(
        json['precio'].toString(),
      ), //conversión segura de precio a double
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
