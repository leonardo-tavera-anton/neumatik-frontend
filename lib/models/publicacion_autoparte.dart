//ib/models/publicacion_autoparte.dart
//modelo esta diseñado para mapear exactamente la respuesta json que genera el endpoint

class PublicacionAutoparte {
  final String publicacionId;
  final String nombreParte;
  final String categoria;
  final String? numeroOem;
  final double precio;
  final String condicion; //nuevo, usado, reacondicionado
  final int stock;
  final String ubicacionCiudad;
  final String idVendedor;
  final String vendedorNombreCompleto;

  final String fotoPrincipalUrl;
  final String? descripcionCorta;
  final DateTime fechaPublicacion;
  final bool iaVerificado;

  //cantidad en el carrito
  int cantidadEnCarrito;

  PublicacionAutoparte({
    required this.publicacionId,
    required this.nombreParte,
    required this.categoria,
    this.numeroOem,
    required this.precio,
    required this.condicion,
    required this.stock,
    required this.ubicacionCiudad,

    required this.idVendedor,
    required this.vendedorNombreCompleto,
    required this.fotoPrincipalUrl,
    this.descripcionCorta,
    required this.fechaPublicacion,
    required this.iaVerificado,
    this.cantidadEnCarrito = 1, //por defecto
  });

  factory PublicacionAutoparte.fromJson(Map<String, dynamic> json) {
    //concatenar nombre y apellido del vendedor y proteccion en caso son nulos mostrar vacio aunq no creo q suceda
    final nombreVendedor = json['vendedor_nombre'] ?? '';
    final apellidoVendedor = json['vendedor_apellido'] ?? '';
    final nombreCompleto = '$nombreVendedor $apellidoVendedor'.trim();

    //url de la foto y convertor a tipos
    return PublicacionAutoparte(
      //'?? '' ' para proteger contra valores nulos en campos de texto esto evita el error "null is not a subtype of type string"
      publicacionId: json['publicacion_id'] as String? ?? '',
      nombreParte: json['nombre_parte'] as String? ?? 'Sin Nombre',
      categoria: json['nombre_categoria'] as String? ?? 'Sin Categoría',
      numeroOem: json['numero_oem'] as String?,
      precio:
          double.tryParse(json['precio']?.toString() ?? '0.0') ??
          0.0, //otro tryparse para manejo de nulos seguroo
      condicion: json['condicion'] as String? ?? 'No especificada',
      stock: json['stock'] as int,

      //id  del vendedor siempre se convierta a string para evitar comparaciones con int
      idVendedor: (json['id_vendedor'] ?? '').toString(),
      ubicacionCiudad: json['ubicacion_ciudad'] as String? ?? 'No especificada',
      vendedorNombreCompleto: nombreCompleto,
      descripcionCorta:
          json['descripcion_corta'] as String?, //placeholder si no hay url
      fotoPrincipalUrl:
          json['foto_principal_url'] ??
          'https://via.placeholder.com/150?text=Neumatik',
      fechaPublicacion: DateTime.parse(
        json['fecha_publicacion'] as String,
      ), //TIMESTAMPTZ
      iaVerificado:
          json['ia_verificado'] as bool? ??
          false, //ayuda a los nulo si el LEFT JOIN q llamamos no encuentra IA.
      cantidadEnCarrito: json['cantidadEnCarrito'] as int? ?? 1,
    );
  }

  //metodo toJson para poder guardar en "SharedPreferences"
  Map<String, dynamic> toJson() {
    return {
      'publicacion_id': publicacionId,
      'nombre_parte': nombreParte,
      'nombre_categoria': categoria,
      'numero_oem': numeroOem,
      //el precio como un número lo guardamos como double y no como un string.
      'precio': precio,
      'condicion': condicion,
      'stock': stock,
      'ubicacion_ciudad': ubicacionCiudad,
      'id_vendedor': idVendedor,
      'vendedor_nombre_completo': vendedorNombreCompleto,
      'descripcion_corta': descripcionCorta,
      'foto_principal_url': fotoPrincipalUrl,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'ia_verificado': iaVerificado,
      'cantidadEnCarrito': cantidadEnCarrito,
    };
  }
}
