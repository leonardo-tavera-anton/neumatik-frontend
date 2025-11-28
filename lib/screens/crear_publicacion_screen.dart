import 'dart:io';
import 'dart:typed_data'; // Necesario para leer los bytes de la imagen
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/publicacion_service.dart';

class CrearPublicacionScreen extends StatefulWidget {
  const CrearPublicacionScreen({super.key});

  @override
  State<CrearPublicacionScreen> createState() => _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState extends State<CrearPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _publicacionService = PublicacionService();

  // Controladores para los campos del formulario
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _oemController = TextEditingController();

  // Variables para la imagen y los dropdowns
  File? _imagenSeleccionada;
  Uint8List? _imagenEnBytes; // Para la vista previa en web y móvil
  String _condicionSeleccionada = 'Nuevo';
  int _categoriaSeleccionada = 1; // Default a 'Frenos'

  bool _isLoading = false;

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

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Leemos los bytes de la imagen para la vista previa (compatible con web)
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
        _imagenEnBytes = bytes;
      });
    }
  }

  Future<void> _submitPublicacion() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no hacer nada.
    }

    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecciona una imagen para la publicación.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Subir la imagen al servidor de imágenes y obtener la URL
      final fotoUrl = await _publicacionService.uploadImage(
        _imagenSeleccionada!,
      );

      await _publicacionService.crearPublicacion(
        // 2. Crear la publicación en tu backend usando la URL obtenida
        nombreParte: _nombreController.text,
        idCategoria: _categoriaSeleccionada,
        precio: double.parse(_precioController.text),
        condicion: _condicionSeleccionada,
        stock: int.parse(_stockController.text),
        ubicacionCiudad: _ciudadController.text,
        numeroOem: _oemController.text,
        descripcionCorta: _descripcionController.text,
        fotoUrl: fotoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Publicación creada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volver a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al crear la publicación: ${e.toString().replaceFirst("Exception: ", "")}',
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
        title: const Text('Crear Nueva Publicación'),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imagenEnBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // SOLUCIÓN: Se elimina el Image.file duplicado y se deja solo Image.memory,
                          // que funciona tanto en móvil como en web.
                          child: Image.memory(
                            _imagenEnBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('Toca para seleccionar una imagen'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Campos de texto
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
                decoration: const InputDecoration(
                  labelText: 'Precio (ej: 250.00)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
                  labelText: 'Descripción Corta (Opcional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _oemController,
                decoration: const InputDecoration(
                  labelText: 'Número de Parte / OEM (Opcional)',
                ),
              ),
              const SizedBox(height: 20),

              // Dropdowns
              DropdownButtonFormField<String>(
                value: _condicionSeleccionada,
                items: ['Nuevo', 'Usado', 'Reacondicionado']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null)
                    setState(() => _condicionSeleccionada = value);
                },
                decoration: const InputDecoration(labelText: 'Condición'),
              ),
              const SizedBox(height: 20),
              // NOTA: Este Dropdown de categorías debería llenarse desde la DB.
              // Por ahora, se usan valores fijos basados en tu script SQL.
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
                onChanged: (value) {
                  if (value != null)
                    setState(() => _categoriaSeleccionada = value);
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPublicacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Publicar Autoparte',
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
