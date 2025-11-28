import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa la pantalla de inicio
import 'screens/login_screen.dart'; // Importa la pantalla de login
import 'screens/registro_screen.dart'; // Importa la pantalla de registro
import 'services/auth_service.dart'; // Importa el servicio de autenticación

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
      },
    );
  }
}

// Pantalla intermedia para verificar si el usuario ya está logueado al iniciar la app
class CheckAuthStateScreen extends StatelessWidget {
  const CheckAuthStateScreen({super.key});

  // Determina la ruta inicial consultando el servicio de autenticación
  Future<String> _getInitialRoute() async {
    // Nota: Aunque AuthService se instancia aquí, debe ser un Singleton o usar Provider/Riverpod
    // en una aplicación real para evitar múltiples instancias. Asumimos que AuthService es ligero.
    final authService = AuthService();
    final isLoggedIn = await authService.isUserLoggedIn();
    return isLoggedIn ? '/home' : '/login';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
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
