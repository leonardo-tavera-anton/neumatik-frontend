import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart'; // Importa la pantalla de login
import 'screens/registro_screen.dart'; // Importa la pantalla de registro
import 'screens/perfil_screen.dart'; // Importa la pantalla de perfil
import 'screens/carrito_screen.dart'; // Importa la pantalla de carrito
import 'screens/detalle_publicacion_screen.dart'; // Importa la pantalla de detalle
import 'screens/listado_autopartes_screen.dart'; // Pantalla real del catálogo
import 'screens/ia_reconocimiento_screen.dart'; // Pantalla de IA

import 'services/auth_service.dart'; // Importa el servicio de autenticación
import 'services/data_service.dart'; // Importa el servicio de datos

void main() {
  // Asegura que los servicios de Flutter (como SharedPreferences) estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppState());
}

// Widget para gestionar el estado de los servicios
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveemos una única instancia de AuthService a toda la app.
        Provider<AuthService>(create: (_) => AuthService()),
        // DataService también se provee para ser accesible globalmente.
        Provider<DataService>(create: (_) => DataService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neumatik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tema principal de la aplicación
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
      ),
      // La ruta inicial es nuestra pantalla de verificación de estado
      initialRoute: '/',
      routes: {
        // La ruta inicial que verifica el estado de autenticación
        '/': (context) => const CheckAuthStateScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistroScreen(),
        '/home': (context) => ListadoAutopartesScreen(), // Usamos la pantalla de listado real
        '/perfil': (context) => const PerfilScreen(),
        '/carrito': (context) => const CarritoScreen(),
        // La ruta de detalle es dinámica, pero la dejamos definida para referencia
        '/publicacion': (context) => const DetallePublicacionScreen(),
        '/ia-reconocimiento': (context) => const IAReconocimientoScreen(),
      },
    );
  }
}

// Pantalla intermedia para verificar si el usuario ya está logueado al iniciar la app
class CheckAuthStateScreen extends StatelessWidget {
  const CheckAuthStateScreen({super.key});

  /// Determina la ruta inicial consultando el servicio de autenticación.
  /// Recibe [authService] para evitar problemas de alcance.
  Future<String> _getInitialRoute(AuthService authService) async {
    final isLoggedIn = await authService.isUserLoggedIn();
    return isLoggedIn ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia de AuthService desde el Provider.
    final authService = context.read<AuthService>();

    return FutureBuilder<String>(
      // Pasamos el servicio al método para que pueda usarlo.
      future: _getInitialRoute(authService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Si tenemos el resultado, navegamos. Usamos addPostFrameCallback para evitar errores
          // al intentar navegar durante la fase de construcción.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Reemplaza la pantalla actual con la ruta destino (login o home)
            Navigator.of(context).pushReplacementNamed(snapshot.data!);
          });
        }

        // Muestra un indicador de carga mientras se verifica el estado de persistencia
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.teal)),
        );
      },
    );
  }
}
