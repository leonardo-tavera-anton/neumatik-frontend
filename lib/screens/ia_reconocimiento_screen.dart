import 'package:flutter/material.dart';
import 'dart:typed_data'; //para manejo d bytes d iamgenes como ya mencione
import 'package:image_picker/image_picker.dart';
import '../services/ia_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; //este paquete renderiza markdown

class IAReconocimientoScreen extends StatefulWidget {
  const IAReconocimientoScreen({super.key});

  @override
  State<IAReconocimientoScreen> createState() => _IAReconocimientoScreenState();
}

class _IAReconocimientoScreenState extends State<IAReconocimientoScreen> {
  Uint8List? _imageBytes;
  String _analysisResult =
      'Sube una foto de la autoparte para comenzar el análisis de Neumatik AI.';

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final IAService _iaService = IAService();

  //funcion d seleccion d imagenes
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _analysisResult =
            'Imagen seleccionada. Presiona "Analizar con IA" para obtener resultados.';
      });
    }
  }

  //esta funcion sirve para tomar fotos con la camara
  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _analysisResult =
            'Imagen capturada. Presiona "Analizar con IA" para obtener resultados.';
      });
    }
  }

  //funcion para enviar imagen
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
      //llamada unica y simplificada
      final specificResult = await _iaService.analizarImagen(_imageBytes!);
      setState(() {
        _analysisResult = specificResult;
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
      appBar: AppBar(title: const Text('Neumatik AI: Autopartes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height:
                  350, //aqui si a futuro quiero CAMBIAR TAMAÑO IMAGEN (no abusar)
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

            //por ultimo botones
            Row(
              children: [
                //boton d galeria
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                //boton camara
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _takePicture, //takePicture llama a la camara arriba mencionado
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //y finalmente boton para iniciar el analisis
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

            //resultados
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
                //markdownBody para renderizar el formato de la IA
                data: _analysisResult,
                selectable:
                    true, //esto deja copiar lo q puso la IA importante para cambiar modificar eliminar
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
