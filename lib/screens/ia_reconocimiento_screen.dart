import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Paquete necesario para seleccionar imágenes
// import '../services/ia_service.dart'; // Descomentar al crear el servicio de IA

class IAReconocimientoScreen extends StatefulWidget {
  const IAReconocimientoScreen({super.key});

  @override
  State<IAReconocimientoScreen> createState() => _IAReconocimientoScreenState();
}

class _IAReconocimientoScreenState extends State<IAReconocimientoScreen> {
  File? _selectedImage;
  // Estado para mostrar el resultado del análisis
  String _analysisResult =
      'Sube una foto de la autoparte para comenzar el análisis de Neumatik AI.';
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  // final IAService _iaService = IAService(); // Descomentar al crear el servicio

  // 1. Función para seleccionar la imagen
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _analysisResult =
            'Imagen seleccionada. Presiona "Analizar con IA" para obtener resultados.';
      });
    }
  }

  // 2. Función para enviar la imagen al modelo de IA
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
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
      // AQUÍ IRÁ LA INTEGRACIÓN REAL CON GEMINI A TRAVÉS DE IAService
      // final result = await _iaService.analyzeImage(_selectedImage!);

      // Simulación de respuesta (ESTO DEBE SER REEMPLAZADO por el llamado real)
      await Future.delayed(const Duration(seconds: 3));
      const simulatedResult = """
      **Análisis Detallado de Autoparte**
      
      * **Parte Detectada:** Pastillas de Freno (Eje Delantero)
      * **Número OEM Sugerido:** 41060-6RA9A
      * **Material:** Compuesto Cerámico (Alta resistencia)
      * **Condición Estimada:** Usado (70% de vida útil restante)
      * **Compatibilidad Tentativa:** Nissan Sentra (2018-2023)
      
      *Conclusión AI: Validación de alta confianza. Esta parte parece genuina y compatible con modelos recientes de Nissan.*
      """;

      setState(() {
        _analysisResult = simulatedResult;
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
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
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
              child: SelectableText(
                // Usamos SelectableText para permitir copiar el resultado
                _analysisResult,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
