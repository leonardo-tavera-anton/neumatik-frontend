import 'package:flutter/material.dart';
import 'dart:typed_data'; // Necesario para manejar bytes de imagen (compatible con web)
import 'package:image_picker/image_picker.dart'; // Paquete necesario para seleccionar imágenes
import '../services/ia_service.dart'; // Importamos el servicio de IA que creamos
import 'package:flutter_markdown/flutter_markdown.dart'; // Paquete para renderizar Markdown

class IAReconocimientoScreen extends StatefulWidget {
  const IAReconocimientoScreen({super.key});

  @override
  State<IAReconocimientoScreen> createState() => _IAReconocimientoScreenState();
}

class _IAReconocimientoScreenState extends State<IAReconocimientoScreen> {
  // Almacenamos los bytes de la imagen para compatibilidad con web y móvil
  Uint8List? _imageBytes;
  // Estado para mostrar el resultado del análisis
  String _analysisResult =
      'Sube una foto de la autoparte para comenzar el análisis de Neumatik AI.';
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final IAService _iaService =
      IAService(); // Instanciamos nuestro servicio de IA

  // 1. Función para seleccionar la imagen
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Leemos los bytes de la imagen para la vista previa y el envío a la IA
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _analysisResult =
            'Imagen seleccionada. Presiona "Analizar con IA" para obtener resultados.';
      });
    }
  }

  // 2. Función para enviar la imagen al modelo de IA
  Future<void> _analyzeImage() async {
    if (_imageBytes == null) {
      setState(() {
        _analysisResult = 'Por favor, selecciona una imagen primero.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _analysisResult = 'Analizando imagen, por favor espera...';
    });

    try {
      // ¡Llamada real al servicio de IA!
      // Enviamos los bytes de la imagen y esperamos el resultado.
      final result = await _iaService.analizarImagen(_imageBytes!);

      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Error al procesar la imagen con IA: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neumatik AI: Reconocimiento de Partes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de la Imagen Seleccionada o Placeholder
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          size: 60,
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Haz clic para seleccionar la foto de la autoparte',
                          style: TextStyle(color: Colors.teal[700]),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            // Botón para seleccionar imagen
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar Imagen de Galería'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón para iniciar el análisis
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzeImage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.rocket_launch),
              label: Text(_isLoading ? 'Analizando...' : 'Analizar con IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Sección de Resultados
            const Text(
              'Resultados del Análisis IA:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(color: Colors.teal),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: MarkdownBody(
                // Usamos MarkdownBody para renderizar el formato de la IA
                data: _analysisResult,
                selectable: true, // Permite al usuario copiar el texto
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
