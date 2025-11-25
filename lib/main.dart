import 'package:flutter/material.dart';

// =========================================================
// 1. IMPORTS DE LAS 5 PANTALLAS
// Importamos todas las pantallas que forman parte del sistema de rutas.
// =========================================================
import 'screens/home_screen.dart'; // RUTA: '/' (Catálogo Principal)
import 'screens/detalle_publicacion_screen.dart'; // RUTA: '/publicacion' (Detalle con ID)
import 'screens/carrito_screen.dart'; // RUTA: '/carrito' (Carrito de Compras)
import 'screens/perfil_screen.dart'; // RUTA: '/perfil' (Perfil/Dashboard)
import 'screens/ia_reconocimiento_screen.dart'; // RUTA: '/ia-reconocimiento' (Herramienta IA)

void main() {
  // Aseguramos que Flutter esté inicializado antes de correr la app
  WidgetsFlutterBinding.ensureInitialized();
  // Correr la aplicación
  runApp(const NeumatikApp());
}

// Renombramos la clase principal a NeumatikApp
class NeumatikApp extends StatelessWidget {
  const NeumatikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neumatik Autopartes',
      debugShowCheckedModeBanner: false,

      // =========================================================
      // 2. CONFIGURACIÓN DEL TEMA
      // =========================================================
      theme: ThemeData(
        primarySwatch: Colors.teal, // Color principal: Teal
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white, // Títulos y textos en blanco
          iconTheme: IconThemeData(
            color: Colors.white,
          ), // Iconos también blancos
        ),
      ),

      // =========================================================
      // 3. SISTEMA DE RUTAS (NAVEGACIÓN)
      // Usamos 'initialRoute' y 'routes' en lugar de la propiedad 'home'.
      // =========================================================

      // Define la ruta inicial (Catálogo)
      initialRoute: '/',

      // Define las rutas estáticas (sin argumentos)
      routes: {
        '/': (context) => const HomeScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/ia-reconocimiento': (context) => const IAReconocimientoScreen(),
      },

      // Define cómo manejar las rutas dinámicas (esencial para Detalle de Producto)
      onGenerateRoute: (settings) {
        // Manejador para la ruta de detalle de publicación, que necesita el ID del producto
        if (settings.name == '/publicacion') {
          // Extraemos los argumentos (el ID)
          final args = settings.arguments as Map<String, dynamic>?;
          final publicacionId = args?['id'] as String?;

          return MaterialPageRoute(
            builder: (context) =>
                DetallePublicacionScreen(publicacionId: publicacionId),
          );
        }
        return null; // Dejamos que Flutter maneje el resto
      },
    );
  }
}
