import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'mis_publicaciones_screen.dart'; // Importamos la nueva pantalla

// RUTA ASIGNADA: '/perfil'
// FUNCIÓN: Dashboard para gestión de perfil, historial y publicaciones (vendedor).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _authService = AuthService();
  Future<Map<String, dynamic>>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _authService.fetchUserProfile();
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        // Navega a la pantalla de login y elimina todas las rutas anteriores.
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // SOLUCIÓN: El FutureBuilder ahora envuelve todo el Scaffold.
    return FutureBuilder<Map<String, dynamic>>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error al cargar el perfil: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No se encontraron datos del perfil.'),
          );
        }

        // Ahora los datos vienen dentro de la clave 'user' para ser consistentes.
        final perfil = snapshot.data!['user'] as Map<String, dynamic>;

        // Se construye el Scaffold aquí, cuando ya tenemos los datos.
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil'),
            backgroundColor: Colors.teal,
            actions: [
              // Ahora el botón SÍ puede ver la variable 'snapshot'.
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/edit-perfil',
                    arguments:
                        perfil, // Pasamos el mapa del perfil directamente.
                  );
                },
              ),
            ],
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.teal),
                  title: const Text('Nombre Completo'),
                  subtitle: Text(
                    '${perfil['nombre'] ?? ''} ${perfil['apellido'] ?? ''}',
                  ),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.email_outlined, color: Colors.teal),
                  title: const Text('Correo Electrónico'),
                  subtitle: Text(perfil['correo'] ?? 'No disponible'),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.phone_outlined, color: Colors.teal),
                  title: const Text('Teléfono'),
                  subtitle: Text(perfil['telefono'] ?? 'No especificado'),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.storefront_outlined,
                    color: Colors.teal,
                  ),
                  title: const Text('Tipo de Cuenta'),
                  subtitle: Text(
                    perfil['es_vendedor'] == true ? 'Vendedor' : 'Comprador',
                  ),
                ),
              ),

              // SOLUCIÓN: Sección "Mis Publicaciones" solo para vendedores.
              if (perfil['es_vendedor'] == true)
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.store_mall_directory_outlined,
                      color: Colors.teal,
                    ),
                    title: const Text('Mis Publicaciones'),
                    subtitle: const Text('Gestiona tus productos a la venta'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // CORRECCIÓN: Usamos la ruta con nombre definida en main.dart
                      Navigator.pushNamed(context, '/mis-publicaciones');
                    },
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
