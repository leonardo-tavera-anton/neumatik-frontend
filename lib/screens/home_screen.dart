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
  // Mantenemos una lista completa y una lista filtrada en el estado.
  List<PublicacionAutoparte> _allPublicaciones = [];
  List<PublicacionAutoparte> _filteredPublicaciones = [];
  bool _isLoading = true;
  String? _error;

  // Controladores y variables para la búsqueda y filtros
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedCondicion;
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _minPrecioController = TextEditingController();
  final TextEditingController _maxPrecioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFiltersAndSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFiltersAndSearch);
    _searchController.dispose();
    _ciudadController.dispose();
    _minPrecioController.dispose();
    _maxPrecioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _reloadData();
  }

  // Función para recargar los datos con RefreshIndicator
  Future<void> _reloadData() async {
    // Para evitar un parpadeo, solo mostramos el indicador de carga si no es la carga inicial.
    if (!_isLoading) {
      setState(
        () {},
      ); // Reconstruye para mostrar el indicador de RefreshIndicator
    }
    try {
      final publications = await _publicacionService.getPublicacionesActivas();
      setState(() {
        _allPublicaciones = publications;
        _filteredPublicaciones = publications;
        _isLoading = false;
        _error = null; // Limpiamos errores previos si la carga es exitosa
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Lógica central para aplicar todos los filtros y la búsqueda
  void _applyFiltersAndSearch() {
    List<PublicacionAutoparte> tempFilteredList = _allPublicaciones;

    // 1. Filtro de búsqueda por texto
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.nombreParte.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // 2. Filtro por categoría
    if (_selectedCategoria != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.categoria == _selectedCategoria;
      }).toList();
    }

    // 3. Filtro por condición
    if (_selectedCondicion != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.condicion == _selectedCondicion;
      }).toList();
    }

    // 4. Filtro por ciudad
    final ciudadQuery = _ciudadController.text.toLowerCase();
    if (ciudadQuery.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.ubicacionCiudad.toLowerCase().contains(ciudadQuery);
      }).toList();
    }

    // 5. Filtro por precio mínimo
    final minPrecio = double.tryParse(_minPrecioController.text);
    if (minPrecio != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.precio >= minPrecio;
      }).toList();
    }

    // 6. Filtro por precio máximo
    final maxPrecio = double.tryParse(_maxPrecioController.text);
    if (maxPrecio != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.precio <= maxPrecio;
      }).toList();
    }

    setState(() {
      _filteredPublicaciones = tempFilteredList;
    });
  }

  // Limpia todos los filtros y la búsqueda
  void _clearFilters() {
    _searchController.clear();
    _ciudadController.clear();
    _minPrecioController.clear();
    _maxPrecioController.clear();
    setState(() {
      _selectedCategoria = null;
      _selectedCondicion = null;
      _filteredPublicaciones = _allPublicaciones;
    });
    Navigator.pop(context); // Cierra el BottomSheet
  }

  // Aplica los filtros del BottomSheet
  void _applyFiltersFromSheet() {
    _applyFiltersAndSearch();
    Navigator.pop(context); // Cierra el BottomSheet
  }

  // Extrae las categorías únicas de las publicaciones
  List<String> _getUniqueCategories() {
    return _allPublicaciones.map((p) => p.categoria).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El Drawer que añadiremos después añade el botón de menú (hamburguesa)
        // SOLUCIÓN: Barra de búsqueda integrada en el AppBar
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre...',
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Mi Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/perfil');
            },
          ),
        ],
      ),
      drawer:
          const AppDrawer(), // SOLUCIÓN: Se vuelve a añadir el Drawer al Scaffold.
      body: RefreshIndicator(
        onRefresh: _reloadData,
        color: Colors.teal,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error al cargar publicaciones: $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            : _filteredPublicaciones.isEmpty
            ? const Center(
                child: Text(
                  'No se encontraron publicaciones con esos criterios.',
                ),
              )
            : ListView.builder(
                itemCount: _filteredPublicaciones.length,
                itemBuilder: (context, index) {
                  final publicacion = _filteredPublicaciones[index];
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
        foregroundColor: Colors
            .white, // CORRECCIÓN: Asegura que el texto y el ícono sean blancos
      ),
    );
  }

  // Muestra el panel de filtros
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el sheet sea más alto
      builder: (context) {
        // Usamos un StatefulBuilder para que los cambios en los dropdowns se reflejen dentro del sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Filtros de Búsqueda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),

                    // Filtro por Categoría
                    DropdownButtonFormField<String>(
                      value: _selectedCategoria,
                      hint: const Text('Seleccionar Categoría'),
                      items: _getUniqueCategories()
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => _selectedCategoria = value),
                      decoration: const InputDecoration(labelText: 'Categoría'),
                    ),
                    const SizedBox(height: 16),

                    // Filtro por Condición
                    DropdownButtonFormField<String>(
                      value: _selectedCondicion,
                      hint: const Text('Seleccionar Condición'),
                      items: ['Nuevo', 'Usado', 'Reacondicionado']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => _selectedCondicion = value),
                      decoration: const InputDecoration(labelText: 'Condición'),
                    ),
                    const SizedBox(height: 16),

                    // Filtro por Ciudad
                    TextFormField(
                      controller: _ciudadController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad de Ubicación',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtro por Precio
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minPrecioController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Mín.',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxPrecioController,
                            decoration: const InputDecoration(
                              labelText: 'Precio Máx.',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Botones de Acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFiltersFromSheet,
                            child: const Text('Aplicar Filtros'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// SOLUCIÓN: Se reincorpora el widget del menú lateral (Drawer) que fue eliminado por error.
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
          // Opción "Mis Publicaciones" solo para vendedores.
          if (_esVendedor)
            ListTile(
              leading: const Icon(Icons.store_mall_directory_outlined),
              title: const Text('Mis Publicaciones'),
              onTap: () {
                Navigator.pop(context);
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
    try {
      await _authService.logout();
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
                  'S/ ${publicacion.precio.toStringAsFixed(2)}', // CORRECCIÓN: Unificamos la moneda a Soles.
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
