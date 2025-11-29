import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/auth_service.dart';
import '../services/publicacion_service.dart';

// RUTA ASIGNADA: '/' (Ruta inicial)
// FUNCIÓN: Muestra el catálogo principal de autopartes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Usamos el servicio de publicaciones correcto.
  final PublicacionService _publicacionService = PublicacionService();
  late Future<List<PublicacionAutoparte>> _publicacionesFuture;

  @override
  void initState() {
    super.initState();
    _publicacionesFuture = _publicacionService.getPublicacionesActivas();
  }

  // Función para recargar los datos con RefreshIndicator
  Future<void> _reloadData() async {
    setState(() {
      _publicacionesFuture = _publicacionService.getPublicacionesActivas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El Drawer automáticamente añade el botón de menú (hamburguesa)
        title: const Text('Neumatik: Autopartes en Venta'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/perfil');
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Reconocimiento por IA',
            onPressed: () {
              Navigator.pushNamed(context, '/ia-reconocimiento');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Carrito de Compras',
            onPressed: () {
              Navigator.pushNamed(context, '/carrito');
            },
          ),
        ],
      ),
      // MEJORA: Se añade el menú lateral (Drawer).
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _reloadData,
        color: Colors.teal,
        child: FutureBuilder<List<PublicacionAutoparte>>(
          future: _publicacionesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error al cargar publicaciones: ${snapshot.error.toString().replaceFirst("Exception: ", "")}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No hay publicaciones disponibles.'),
              );
            }

            final publicaciones = snapshot.data!;
            return ListView.builder(
              itemCount: publicaciones.length,
              itemBuilder: (context, index) {
                final publicacion = publicaciones[index];
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/publicacion',
                      arguments: publicacion.publicacionId,
                    );
                  },
                  child: AutoparteCard(publicacion: publicacion),
                );
              },
            );
          },
        ),
      ),
      // MEJORA: Botón flotante para crear nuevas publicaciones.
      // Es un estándar de UX en apps móviles.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/crear-publicacion');
        },
        label: const Text('Vender'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.teal.shade700,
      ),
    );
  }
}

// SOLUCIÓN: Convertimos el Drawer a StatefulWidget para que sea dinámico.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  bool _esVendedor = false;

  @override
  void initState() {
    super.initState();
    _verificarRolVendedor();
  }

  // Verifica si el usuario es vendedor para mostrar opciones adicionales.
  Future<void> _verificarRolVendedor() async {
    try {
      // Usamos el mismo servicio que la pantalla de perfil.
      final perfilData = await _authService.fetchUserProfile();
      final perfil = perfilData['user'] as Map<String, dynamic>;
      if (mounted && perfil['es_vendedor'] == true) {
        setState(() {
          _esVendedor = true;
        });
      }
    } catch (e) {
      // Si hay un error (ej. token expirado), no se muestra la opción.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?q=80&w=2070', // Imagen de fondo genérica
                ),
                opacity: 0.3,
              ),
            ),
            child: Text(
              'Neumatik App',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context), // Cierra el drawer
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer primero
              Navigator.pushNamed(context, '/perfil');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Carrito'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/carrito');
            },
          ),
          // SOLUCIÓN: Opción "Mis Publicaciones" solo para vendedores.
          if (_esVendedor)
            ListTile(
              leading: const Icon(Icons.store_mall_directory_outlined),
              title: const Text('Mis Publicaciones'),
              onTap: () {
                Navigator.pop(context);
                // Usamos la nueva ruta que crearemos en main.dart
                Navigator.pushNamed(context, '/mis-publicaciones');
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () => _logout(context), // Llama a la función de logout
          ),
        ],
      ),
    );
  }

  // Función para manejar el logout desde el Drawer.
  void _logout(BuildContext context) async {
    final authService = AuthService();
    try {
      await authService.logout();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      // Manejo de error si el logout falla
    }
  }
}

// Widget para el diseño de cada tarjeta de autoparte
class AutoparteCard extends StatelessWidget {
  final PublicacionAutoparte publicacion;

  const AutoparteCard({Key? key, required this.publicacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      clipBehavior: Clip
          .antiAlias, // Recorta la imagen para que se ajuste a los bordes redondeados
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.network(
              publicacion.fotoPrincipalUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.teal),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.car_crash,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            ),
          ),
          // Contenido de texto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  publicacion.nombreParte,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${publicacion.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(publicacion.condicion),
                      backgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    if (publicacion.iaVerificado)
                      const Tooltip(
                        message: 'Verificado por IA',
                        child: Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Vendido por: ${publicacion.vendedorNombreCompleto}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
