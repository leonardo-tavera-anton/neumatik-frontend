import 'package:flutter/material.dart';

// RUTA ASIGNADA: '/perfil'
// FUNCIÓN: Dashboard para gestión de perfil, historial y publicaciones (vendedor).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Simulación de si el usuario es vendedor
  final bool isVendedor = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil y Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, [Nombre de Usuario]!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(height: 30),

            // Sección General
            const Text(
              'Historial de Compras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Ver órdenes pasadas (Tabla: ordenes)'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const ListTile(
              leading: Icon(Icons.rate_review),
              title: Text('Mis Reviews (Tabla: reviews)'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),

            if (isVendedor) ...[
              const Divider(height: 30),
              // Panel de Vendedor
              const Text(
                'Panel de Vendedor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Gestionar Publicaciones (CRUD)'),
                subtitle: const Text(
                  'Ver stock, IA status (analisis_ia) y editar',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Lógica para ir a la gestión de inventario
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle),
                title: const Text('Crear Nueva Publicación'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Lógica para crear una nueva publicación
                },
              ),
            ],

            const Divider(height: 30),
            // Configuración
            const Text(
              'Configuración',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Editar datos de usuario (Tabla: usuarios)'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
