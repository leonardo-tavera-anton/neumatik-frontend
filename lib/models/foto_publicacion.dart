
// Modelo para una foto asociada a una Publicación
class FotoPublicacion {
  final String fotoId;
  final String publicacionId;
  final String url;
  final bool esPrincipal;

  FotoPublicacion({
    required this.fotoId,
    required this.publicacionId,
    required this.url,
    required this.esPrincipal,
  });

  factory FotoPublicacion.fromJson(Map<String, dynamic> json) {
    return FotoPublicacion(
      fotoId: json['id'] as String,
      publicacionId: json['id_publicacion'] as String,
      url: json['url'] as String,
      esPrincipal: json['es_principal'] as bool? ?? false,
    );
  }
}
