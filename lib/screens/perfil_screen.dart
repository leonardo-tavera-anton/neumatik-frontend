import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

// RUTA ASIGNADA: '/perfil'
// FUNCIÓN: Dashboard para gestión de perfil, historial y publicaciones (vendedor).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<Usuario> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    // Usamos Provider para obtener el servicio y llamar al método.
    // `listen: false` es importante en initState.
    final authService = Provider.of<AuthService>(context, listen: false);
    _userProfileFuture = authService
        .fetchUserProfile()
        .then((profileMap) => Usuario.fromJson(profileMap));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil y Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              // Lógica para cerrar sesión
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              // Navegar a la pantalla de login y eliminar el historial de rutas
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final usuario = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${usuario.nombre}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(usuario.correo,
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const Divider(height: 30),
                  const Text(
                    'Historial de Compras',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const ListTile(
                    leading: Icon(Icons.receipt),
                    title: Text('Ver órdenes pasadas'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  const ListTile(
                    leading: Icon(Icons.rate_review),
                    title: Text('Mis Reviews'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  if (usuario.esVendedor) ...[
                    const Divider(height: 30),
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
                      title: const Text('Gestionar Publicaciones'),
                      subtitle: const Text('Ver stock, estado y editar'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_circle),
                      title: const Text('Crear Nueva Publicación'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {},
                    ),
                  ],
                  const Divider(height: 30),
                  const Text(
                    'Configuración',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Editar datos de perfil'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
                ),
            );
          }
          return const Center(child: Text('No se pudo cargar el perfil.'));
        },
      ),
    );
  }
}
