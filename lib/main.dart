import 'package:flutter/material.dart';
import '../screens/listado_autopartes_screen.dart';

void main() {
  // Aseguramos que Flutter esté inicializado antes de correr la app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Este widget es la raíz de tu aplicación.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título que aparece en el gestor de tareas del dispositivo
      title: 'Neumatik Autopartes',

      // Tema general de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.teal, // Color principal de la app
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white, // Título de AppBar en blanco
        ),
      ),

      // La pantalla inicial de la aplicación es el listado de autopartes
      home: ListadoAutopartesScreen(),

      // Ocultar la etiqueta de debug en la esquina
      debugShowCheckedModeBanner: false,
    );
  }
}
