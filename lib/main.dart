import 'package:flutter/material.dart';

// =========================================================
// 1. IMPORTS DE AUTENTICACIÓN Y PANTALLAS
// =========================================================
import 'package:shared_preferences/shared_preferences.dart'; // Necesario para asegurar la inicialización
import 'services/auth_service.dart'; // Importamos el servicio de autenticación
import 'screens/login_screen.dart'; // Importamos la nueva pantalla de Login

// Imports de las 5 pantallas originales
import 'screens/home_screen.dart'; // RUTA: '/' (Catálogo Principal)
import 'screens/detalle_publicacion_screen.dart'; // RUTA: '/publicacion' (Detalle con ID)
import 'screens/carrito_screen.dart'; // RUTA: '/carrito' (Carrito de Compras)
import 'screens/perfil_screen.dart'; // RUTA: '/perfil' (Perfil/Dashboard)
import 'screens/ia_reconocimiento_screen.dart'; // RUTA: '/ia-reconocimiento' (Herramienta IA)

void main() async {
  // Aseguramos que Flutter esté inicializado antes de correr la app y usar SharedPreferences
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
      // 2. CONFIGURACIÓN DEL TEMA (Se mantiene igual)
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
      // 3. SISTEMA DE RUTAS Y VERIFICACIÓN DE SESIÓN (MODIFICADO)
      // =========================================================

      // Usamos 'home' para la lógica de verificación inicial de sesión.
      home: FutureBuilder<bool>(
        // Verificamos si el usuario ya tiene un token guardado.
        future: AuthService().isUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras espera, muestra un splash screen o un indicador de carga
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Si el usuario está logueado (tiene un token válido)
          final bool isLoggedIn = snapshot.data ?? false;

          if (isLoggedIn) {
            // El usuario ya está autenticado, vamos al sistema de rutas principal.
            return _AppNavigator();
          } else {
            // El usuario NO está autenticado, mostramos la pantalla de login.
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

// =========================================================
// WIDGET AUXILIAR PARA EL SISTEMA DE RUTAS
// (Reutilizamos la lógica original de rutas si el usuario está logueado)
// =========================================================
class _AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Se mantiene la configuración de rutas
      initialRoute: '/',

      // Define las rutas estáticas (sin argumentos)
      routes: {
        '/': (context) => const HomeScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/ia-reconocimiento': (context) => const IAReconocimientoScreen(),
      },

      // Define cómo manejar las rutas dinámicas
      onGenerateRoute: (settings) {
        if (settings.name == '/publicacion') {
          final args = settings.arguments as Map<String, dynamic>?;
          final publicacionId = args?['id'] as String?;

          return MaterialPageRoute(
            builder: (context) =>
                DetallePublicacionScreen(publicacionId: publicacionId),
          );
        }
        return null;
      },
    );
  }
}
