// lib/screens/edit_publicacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/publicacion_autoparte.dart';
import '../services/publicacion_service.dart';

class EditPublicacionScreen extends StatefulWidget {
  final PublicacionAutoparte publicacion;

  const EditPublicacionScreen({super.key, required this.publicacion});

  @override
  State<EditPublicacionScreen> createState() => _EditPublicacionScreenState();
}

class _EditPublicacionScreenState extends State<EditPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _publicacionService = PublicacionService();

  //los mismo controladores para los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _descripcionController;
  late TextEditingController _oemController;

  late String _condicionSeleccionada;
  late String _ciudadSeleccionada; //dropdown de ciudad
  late int _categoriaSeleccionada;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.publicacion.nombreParte,
    );
    _precioController = TextEditingController(
      text: widget.publicacion.precio.toString(),
    );
    _stockController = TextEditingController(
      text: widget.publicacion.stock.toString(),
    );
    _descripcionController = TextEditingController(
      text: widget.publicacion.descripcionCorta ?? '',
    );
    _oemController = TextEditingController(
      text: widget.publicacion.numeroOem ?? '',
    );

    final ciudadGuardada = widget.publicacion.ubicacionCiudad;
    if (_getCiudadesPrincipales().contains(ciudadGuardada)) {
      _ciudadSeleccionada = ciudadGuardada;
    } else {
      _ciudadSeleccionada =
          _getCiudadesPrincipales()[0]; //se verifica y se asigna la primera ciudad de la lista como valor por defecto esto 2 veces q salio mal en el commit
    }
    _condicionSeleccionada = widget.publicacion.condicion;
    _categoriaSeleccionada = _mapCategoriaToId(
      widget.publicacion.categoria,
    ); //para el "mapeo"
  }

  //y su auxiliar al momento d mapear los datos
  int _mapCategoriaToId(String nombreCategoria) {
    final categorias = {
      'Frenos': 1,
      'Suspensión y Dirección': 2,
      'Motor': 3,
      'Filtros': 4,
      'Sistema Eléctrico': 5,
      'Carrocería': 6,
      'Neumáticos y Ruedas': 7,
    };
    return categorias[nombreCategoria] ??
        1; //igual tmb asigno valor 1 como en crear publicacion q son los "frenos" solo para no olvidarme
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _oemController.dispose();
    super.dispose();
  }

  //lista de ciudades para el dropdown.
  List<String> _getCiudadesPrincipales() {
    return [
      'Lima',
      'Arequipa',
      'Trujillo',
      'Chiclayo',
      'Chimbote',
      'Chincha Alta',
      'Cusco',
      'Huancayo',
      'Huánuco',
      'Huaraz',
      'Ica',
      'Iquitos',
      'Nuevo Chimbote',
      'Juliaca',
      'Piura',
      'Pucallpa',
      'Puno',
      'Sullana',
      'Tacna',
      'Tumbes',
    ]..sort();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      //llamamos a la nueva funcion para actualizar publicac
      await _publicacionService.updatePublicacion(
        publicacionId: widget.publicacion.publicacionId,
        nombreParte: _nombreController.text,
        idCategoria: _categoriaSeleccionada,
        precio: double.parse(_precioController.text),
        condicion: _condicionSeleccionada,
        stock: int.parse(_stockController.text),
        ubicacionCiudad: _ciudadSeleccionada,
        numeroOem: _oemController.text,
        descripcionCorta: _descripcionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación actualizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        //volver a las publicaciones y recargar todo waaaaaaa
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
        Navigator.of(context).pushNamed('/mis-publicaciones');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Publicación'),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //sin edicion d imagenes
              Image.network(
                widget.publicacion.fotoPrincipalUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Autoparte',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) =>
                    v!.isEmpty ? 'El precio es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad en Stock',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.isEmpty ? 'El stock es obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción Corta',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _oemController,
                decoration: const InputDecoration(
                  labelText: 'Número de Parte / OEM',
                ),
              ),
              const SizedBox(height: 20),

              //dropdowns necesarios
              DropdownButtonFormField<String>(
                value: _condicionSeleccionada,
                items: ['Nuevo', 'Usado', 'Reacondicionado']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _condicionSeleccionada = value!),
                decoration: const InputDecoration(labelText: 'Condición'),
              ),
              const SizedBox(height: 20),

              //reemplazamos por una ciudad
              DropdownButtonFormField<String>(
                value: _ciudadSeleccionada,
                items: _getCiudadesPrincipales()
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _ciudadSeleccionada = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Ciudad de Ubicación',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _categoriaSeleccionada,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Frenos')),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Suspensión y Dirección'),
                  ),
                  DropdownMenuItem(value: 3, child: Text('Motor')),
                  DropdownMenuItem(value: 4, child: Text('Filtros')),
                  DropdownMenuItem(value: 5, child: Text('Sistema Eléctrico')),
                  DropdownMenuItem(value: 6, child: Text('Carrocería')),
                  DropdownMenuItem(
                    value: 7,
                    child: Text('Neumáticos y Ruedas'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _categoriaSeleccionada = value!),
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar Cambios',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
