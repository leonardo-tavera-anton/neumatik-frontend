import 'package:flutter/material.dart';

// RUTA ASIGNADA: '/' (Ruta inicial)
// FUNCIÓN: Muestra el catálogo principal de autopartes.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neumatik | Catálogo de Autopartes'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/carrito'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
          ),
        ],
      ),
      drawer: _AppDrawer(context),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car, size: 80, color: Colors.teal),
              SizedBox(height: 16),
              Text(
                'Bienvenido a Neumatik',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Aquí se mostrará el listado de autopartes (Tabla: publicaciones).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget del menú lateral (Drawer)
Widget _AppDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.teal),
          child: Text(
            'Menú Neumatik',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Catálogo Principal'),
          onTap: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text('Perfil / Dashboard'),
          onTap: () {
            Navigator.pushNamed(context, '/perfil');
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Carrito de Compras'),
          onTap: () {
            Navigator.pushNamed(context, '/carrito');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Herramienta IA (Reconocimiento)'),
          onTap: () {
            Navigator.pushNamed(context, '/ia-reconocimiento');
          },
        ),
      ],
    ),
  );
}
