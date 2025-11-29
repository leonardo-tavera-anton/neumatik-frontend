import 'package:flutter/material.dart';
import 'screens/carrito_screen.dart';
import 'screens/home_screen.dart'; // Importa la pantalla de inicio
import 'screens/crear_publicacion_screen.dart';
import 'screens/edit_perfil_screen.dart'; // Importamos la pantalla de edición
import 'screens/detalle_publicacion_screen.dart';
import 'screens/ia_reconocimiento_screen.dart';
import 'screens/mis_publicaciones_screen.dart'; // Importamos la pantalla
import 'screens/login_screen.dart'; // Importa la pantalla de login
import 'screens/perfil_screen.dart';
import 'screens/registro_screen.dart'; // Importa la pantalla de registro
import 'services/auth_service.dart'; // Importa el servicio de autenticación
import 'screens/edit_publicacion_screen.dart';
import 'models/publicacion_autoparte.dart';

// 1. GlobalKey para el Navigator
// Esto permite la navegación desde fuera del árbol de widgets, una práctica robusta.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Asegura que los servicios de Flutter (como SharedPreferences) estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 2. Asignamos el GlobalKey al navigatorKey
      navigatorKey: navigatorKey,
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
        '/home': (context) => const HomeScreen(),
        // 3. RUTAS AÑADIDAS: Se agregan las rutas que faltaban.
        '/perfil': (context) =>
            const PerfilScreen(), // Pantalla de perfil de usuario.
        '/ia-reconocimiento': (context) => const IAReconocimientoScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/edit-perfil': (context) {
          final perfilActual =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditPerfilScreen(perfil: perfilActual);
        },
        // SOLUCIÓN: Añadimos la ruta para la pantalla de "Mis Publicaciones".
        '/mis-publicaciones': (context) => const MisPublicacionesScreen(),
        // SOLUCIÓN: Añadimos la ruta para la pantalla de edición de publicaciones.
        '/edit-publicacion': (context) {
          final publicacion =
              ModalRoute.of(context)!.settings.arguments
                  as PublicacionAutoparte;
          return EditPublicacionScreen(publicacion: publicacion);
        },
        '/crear-publicacion': (context) => const CrearPublicacionScreen(),
        // 4. RUTA DE DETALLE: Ruta para mostrar el detalle de una publicación.
        // Extrae el ID de los argumentos de la ruta.
        '/publicacion': (context) {
          final publicacionId =
              ModalRoute.of(context)!.settings.arguments as String;
          return DetallePublicacionScreen(publicacionId: publicacionId);
        },
      },
    );
  }
}

// Pantalla intermedia para verificar si el usuario ya está logueado al iniciar la app
// SOLUCIÓN: Convertido a StatefulWidget para manejar la lógica de navegación de forma segura en initState.
class CheckAuthStateScreen extends StatefulWidget {
  const CheckAuthStateScreen({super.key});

  @override
  State<CheckAuthStateScreen> createState() => _CheckAuthStateScreenState();
}

class _CheckAuthStateScreenState extends State<CheckAuthStateScreen> {
  @override
  void initState() {
    super.initState();
    // Se llama a la verificación aquí para que se ejecute solo una vez.
    _checkAuthAndNavigate();
  }

  // Determina la ruta inicial consultando el servicio de autenticación
  Future<void> _checkAuthAndNavigate() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();
    final route = isLoggedIn ? '/home' : '/login';
    // Usamos el context del State, asegurándonos de que el widget esté montado.
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Muestra un indicador de carga mientras se realiza la verificación en initState.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}
