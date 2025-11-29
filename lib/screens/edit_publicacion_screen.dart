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

  // Controladores para los campos del formulario
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _descripcionController;
  late TextEditingController _ciudadController;
  late TextEditingController _oemController;

  late String _condicionSeleccionada;
  late int _categoriaSeleccionada;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos de la publicación existente.
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
    _ciudadController = TextEditingController(
      text: widget.publicacion.ubicacionCiudad,
    );
    _oemController = TextEditingController(
      text: widget.publicacion.numeroOem ?? '',
    );

    _condicionSeleccionada = widget.publicacion.condicion;
    // NOTA: Esto asume que tienes una forma de mapear el nombre de la categoría a su ID.
    // Para este ejemplo, lo dejaremos con un valor fijo si no se puede mapear.
    _categoriaSeleccionada = _mapCategoriaToId(widget.publicacion.categoria);
  }

  // Función auxiliar para mapear el nombre de la categoría a su ID.
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
        1; // Devuelve 1 (Frenos) si no lo encuentra.
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _ciudadController.dispose();
    _oemController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Llamamos a la nueva función para actualizar la publicación.
      await _publicacionService.updatePublicacion(
        publicacionId: widget
            .publicacion
            .publicacionId, // CORRECCIÓN: El acceso correcto es widget.publicacion.publicacionId
        nombreParte: _nombreController.text,
        idCategoria: _categoriaSeleccionada,
        precio: double.parse(_precioController.text),
        condicion: _condicionSeleccionada,
        stock: int.parse(_stockController.text),
        ubicacionCiudad: _ciudadController.text,
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
        // Volver a la pantalla de "Mis Publicaciones" y recargarla.
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
              // La imagen no se puede editar por ahora, solo se muestra.
              Image.network(
                widget.publicacion.fotoPrincipalUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),

              // Campos de texto (igual que en crear_publicacion_screen)
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
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad de Ubicación',
                ),
                validator: (v) =>
                    v!.isEmpty ? 'La ciudad es obligatoria' : null,
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

              // Dropdowns
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
