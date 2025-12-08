import 'package:flutter/material.dart';
import 'screens/carrito_screen.dart';
import 'screens/home_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/crear_publicacion_screen.dart';
import 'screens/edit_perfil_screen.dart';
import 'screens/detalle_publicacion_screen.dart';
import 'screens/ia_reconocimiento_screen.dart';
import 'screens/pago_exitoso_screen.dart';
import 'screens/mis_publicaciones_screen.dart';
import 'screens/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/registro_screen.dart';
import 'services/auth_service.dart';
import 'screens/edit_publicacion_screen.dart';
import 'models/publicacion_autoparte.dart';

//global navigator key
//esta clave nos permite navegar sin necesidad de un context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  //asegura que los bindings de flutter esten inicializados
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //asigna la clave global al navigator
      navigatorKey: navigatorKey,
      title: 'Neumatik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //tema principal de la app color celeste turquesa medio raro
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
      ),
      //la ruta inicial es la pantalla que verifica el estado de autenticacion
      initialRoute: '/',
      routes: {
        //la ruta raiz verifica si el usuario esta logueado
        '/': (context) => const CheckAuthStateScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistroScreen(),
        '/home': (context) => const HomeScreen(),
        //se agrega la ruta para la pantalla de perfil
        '/perfil': (context) => const PerfilScreen(), //ruta: /perfil
        '/ia-reconocimiento': (context) => const IAReconocimientoScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/edit-perfil': (context) {
          final perfilActual =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return EditPerfilScreen(perfil: perfilActual);
        },
        //ruta para mis publicaciones
        '/mis-publicaciones': (context) => const MisPublicacionesScreen(),
        //ruta para editar una publicacion
        '/edit-publicacion': (context) {
          final publicacion =
              ModalRoute.of(context)!.settings.arguments
                  as PublicacionAutoparte;
          return EditPublicacionScreen(publicacion: publicacion);
        },
        '/crear-publicacion': (context) => const CrearPublicacionScreen(),
        //ruta para el detalle de una publicacion
        '/publicacion': (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments;
          //verificación para evitar errores durante el hot restart con R*
          //si los argumentos se pierden.
          if (arguments is String) {
            return DetallePublicacionScreen(publicacionId: arguments);
          }
          //si no son validos los argumentos mostramos un error
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('ID de publicación no válido o no encontrado.'),
            ),
          );
        },
        //ruta para la pantalla de pago exitoso
        '/pago-exitoso': (context) => const PagoExitosoScreen(),
        //ruta para la pantalla de checkout
        '/checkout': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CheckoutScreen(
            items: args['items'] as List<PublicacionAutoparte>,
            total: args['total'] as double,
          );
        },
      },
    );
  }
}

//pantalla que verifica el estado de autenticacion y redirige a la pantalla adecuada
class CheckAuthStateScreen extends StatefulWidget {
  const CheckAuthStateScreen({super.key});

  @override
  State<CheckAuthStateScreen> createState() => _CheckAuthStateScreenState();
}

class _CheckAuthStateScreenState extends State<CheckAuthStateScreen> {
  @override
  void initState() {
    super.initState(); //al iniciar el estado
    _checkAuthAndNavigate();
  }

  //dispositivo asincrono para verificar autenticacion y navegar
  Future<void> _checkAuthAndNavigate() async {
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();
    final route = isLoggedIn ? '/home' : '/login';
    //navega a la ruta correspondiente
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    //muestra un indicador de carga mientras verifica
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}
