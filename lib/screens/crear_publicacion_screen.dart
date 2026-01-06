import 'dart:io';
import 'dart:typed_data'; //importamos dado q es necesario para leer los bytes de la imagen
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ia_service.dart';
import '../services/publicacion_service.dart';

class CrearPublicacionScreen extends StatefulWidget {
  const CrearPublicacionScreen({super.key});

  @override
  State<CrearPublicacionScreen> createState() => _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState extends State<CrearPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _publicacionService = PublicacionService();
  final _iaService = IAService(); //instanciamos servicios

  //controladores
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _oemController = TextEditingController();

  //variables para la imagen y los dropdowns
  File? _imagenSeleccionada;
  Uint8List? _imagenEnBytes; //para la vista previa en web y movil
  String? _nombreArchivo; //importante al momento d subir
  String _condicionSeleccionada = 'Nuevo';
  int _categoriaSeleccionada = 1; //como default esta en "frenos"
  String _ciudadSeleccionada =
      'Lima'; //y aqui tmb ciudad en este caso por defecto "lima"

  bool _isLoading = false;
  //definitos tipo d carga booleana a la ia
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _descripcionController.dispose();
    _oemController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile
          .readAsBytes(); //se leen bytes de la imagen para la vista previa (para web)
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
        _nombreArchivo = pickedFile.name;
        _imagenEnBytes = bytes;
      });
    }
  }

  //_analizarYCompletar declaramos funcion para analizar la imagen y rellenar los campos.
  Future<void> _analizarYCompletar() async {
    if (_imagenEnBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen primero.'),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      //trycatch q llama a la funcion d analizar
      final analysis = await _iaService.analizarParaCrear(_imagenEnBytes!);
      _parseAndFillForm(analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en el análisis: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  //funcion para parsear la respuesta de la IA y rellenar el formulario.
  void _parseAndFillForm(String analysis) {
    final lines = analysis.split('\n');
    final validConditions = ['Nuevo', 'Usado', 'Reacondicionado'];
    final Map<String, int> categoriasMap = {
      'Frenos': 1,
      'Suspensión y Dirección': 2,
      'Motor': 3,
      'Filtros': 4,
      'Sistema Eléctrico': 5,
      'Carrocería': 6,
      'Neumáticos y Ruedas': 7,
    };

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts[0].replaceAll(RegExp(r'[\*\-]'), '').trim();
        final value = parts.sublist(1).join(':').trim();

        if (key == 'Nombre de la pieza' && value.isNotEmpty) {
          _nombreController.text = value;
        } else if (key == 'Número de Parte (OEM)' && value.isNotEmpty) {
          _oemController.text = value;
        } else if (key == 'Condición estimada' &&
            validConditions.contains(value) &&
            value.isNotEmpty) {
          setState(() {
            _condicionSeleccionada = value;
          });
        } else if (key == 'Categoría' && categoriasMap.containsKey(value)) {
          setState(() {
            _categoriaSeleccionada = categoriasMap[value]!;
          });
        } else if (key == 'Descripción corta' && value.isNotEmpty) {
          _descripcionController.text = value;
        } else if (key == 'Precio estimado (S/)' && value.isNotEmpty) {
          _precioController.text = value
              .split('-')[0]
              .replaceAll(
                RegExp(r'[^0-9.]'),
                '',
              ) //esto toma el primer · del rango como sugerencia
              .trim();
        }
      }
    }
  }

  Future<void> _submitPublicacion() async {
    if (!_formKey.currentState!.validate()) {
      return; //condicional para no hacer nd si no encuentra
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
      //trycath d la imagen al servidor de imagenes y obtener la url
      final fotoUrl = await _publicacionService.uploadImage(
        _imagenEnBytes!,
        _nombreArchivo!,
      );

      await _publicacionService.crearPublicacion(
        //crea la publicación en tu backend usando la URL obtenida
        nombreParte: _nombreController.text,
        idCategoria: _categoriaSeleccionada,
        precio: double.parse(_precioController.text),
        condicion: _condicionSeleccionada,
        stock: int.parse(_stockController.text),
        ubicacionCiudad: _ciudadSeleccionada, //valor del dropdown.
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
        Navigator.of(context).pop();
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

  //busqueda
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
              //selector de imagen
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

              //boton para analizar con IA y es solo visible si se carga imagen
              if (_imagenEnBytes != null) //condicion
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analizarYCompletar,
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rocket_launch_outlined),
                    label: Text(
                      _isAnalyzing
                          ? 'Analizando...'
                          : 'Analizar con IA para autocompletar',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

              //todos los campos de texto
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
                //solo permite numeros y punto decimal!!!
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  if (double.tryParse(v) == null) {
                    return 'Por favor, introduce un número válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad en Stock',
                ),
                keyboardType: TextInputType.number,
                //solo digitos enteros
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'El stock es obligatorio';
                  }
                  return null;
                },
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

              //dropdowns
              DropdownButtonFormField<String>(
                initialValue: _condicionSeleccionada,
                items: ['Nuevo', 'Usado', 'Reacondicionado']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _condicionSeleccionada = value);
                  }
                },
                decoration: const InputDecoration(labelText: 'Condición'),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _ciudadSeleccionada,
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
                validator: (v) => v == null ? 'La ciudad es obligatoria' : null,
              ),
              const SizedBox(height: 20),
              //dropdown de categorias tendria q llenarse desde la db pero solo usan valores fijos basados en sql d pgadmin4.
              DropdownButtonFormField<int>(
                initialValue: _categoriaSeleccionada,
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
                  if (value != null) {
                    setState(() => _categoriaSeleccionada = value);
                  }
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
