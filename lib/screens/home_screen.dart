import 'package:flutter/material.dart';
import '../models/publicacion_autoparte.dart';
import '../services/auth_service.dart';
import '../services/publicacion_service.dart';

//ruta: '/' (la q sera base)
//mostrando catalogo d autopartes
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PublicacionService _publicacionService = PublicacionService();
  final AuthService _authService = AuthService();
  List<PublicacionAutoparte> _allPublicaciones = [];
  List<PublicacionAutoparte> _filteredPublicaciones = [];
  bool _isLoading = true;
  String? _error;

  //controladores con sus variables necesaras
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoria;
  String? _selectedCiudad;
  String? _selectedCondicion;
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
    _minPrecioController.dispose();
    _maxPrecioController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _reloadData();
  }

  //funcion para recargar los datos con refresh indicator
  Future<void> _reloadData() async {
    if (!_isLoading) {
      //esto es para evitar un parpadeo
      setState(() {}); //RefreshIndicator
    }
    try {
      //y luego sololo cargamos las publicaciones
      final publications = await _publicacionService.getPublicacionesActivas();

      setState(() {
        _allPublicaciones = publications;
        _filteredPublicaciones = publications;
        _isLoading = false;
        _error = null; //para verificar todo fue bien
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  //logica d aplicar busqueda y filtros
  void _applyFiltersAndSearch() {
    List<PublicacionAutoparte> tempFilteredList = _allPublicaciones;

    //por texto
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.nombreParte.toLowerCase().contains(searchQuery);
      }).toList();
    }

    //por categoria
    if (_selectedCategoria != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.categoria == _selectedCategoria;
      }).toList();
    }

    //por condicion
    if (_selectedCondicion != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.condicion == _selectedCondicion;
      }).toList();
    }

    //por ciudad
    if (_selectedCiudad != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.ubicacionCiudad == _selectedCiudad;
      }).toList();
    }

    //por precio minimo
    final minPrecio = double.tryParse(_minPrecioController.text);
    if (minPrecio != null) {
      tempFilteredList = tempFilteredList.where((p) {
        return p.precio >= minPrecio;
      }).toList();
    }

    //por precio maximo
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

  //para limpiar todos los filtros
  void _clearFilters() {
    _searchController.clear();
    _minPrecioController.clear();
    _maxPrecioController.clear();
    setState(() {
      _selectedCategoria = null;
      _selectedCondicion = null;
      _selectedCiudad = null;
      _filteredPublicaciones = _allPublicaciones;
    });
    Navigator.pop(context); //ccierra el bottomsheet
  }

  //igual aqui aplica los filtros
  void _applyFiltersFromSheet() {
    _applyFiltersAndSearch();
    Navigator.pop(context); //y aqui se cierra el bottomsheet
  }

  //categorias
  List<String> _getUniqueCategories() {
    return _allPublicaciones.map((p) => p.categoria).toSet().toList();
  }

  List<String> _getCiudadesPrincipales() {
    return [
      'Lima',
      'Arequipa',
      'Trujillo',
      'Chiclayo',
      'Chimbote',
      'Chincha Alta',
      'Cusco',
      'Huancayo',
      'Huánuco',
      'Huaraz',
      'Ica',
      'Iquitos',
      'Nuevo Chimbote',
      'Juliaca',
      'Piura',
      'Pucallpa',
      'Puno',
      'Sullana',
      'Tacna',
      'Tumbes',
    ]..sort(); //para ordenar alfabeticamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neumatik'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre de autoparte...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
            onPressed: () => _showFilterSheet(context),
          ),
          //boton reconocimiento por IA
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Reconocimiento por IA',
            onPressed: () {
              Navigator.pushNamed(context, '/ia-reconocimiento');
            },
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
          const AppDrawer(), //drawer menu lateral para mas comodidad y q se vea estetico
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
      //boton flotante para crear publicacion
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          //recargamos para q muestre datos
          await Navigator.pushNamed(context, '/crear-publicacion');
          _reloadData();
        },
        label: const Text('Vender'),
        icon: const Icon(Icons.add_circle_outline),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  //show filter osea muestra los filtros
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        //y finalmente usamos un Stateful Builder para que los cambios en los dropdowns se reflejen dentro del sheet
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

                    //por categoria
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

                    //por condicion
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

                    //por ciudad
                    DropdownButtonFormField<String>(
                      value: _selectedCiudad,
                      hint: const Text('Seleccionar Ciudad'),
                      items: _getCiudadesPrincipales()
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => _selectedCiudad = value),
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                    ),
                    const SizedBox(height: 16),

                    //por precio
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

                    //y botones d accion
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

//drawer lateral
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  String? _nombreUsuario;

  @override
  void initState() {
    super.initState();
    _cargarDatosDeUsuario();
  }

  Future<void> _cargarDatosDeUsuario() async {
    try {
      final perfilData = await _authService.fetchUserProfile();
      final perfil = perfilData['user'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _nombreUsuario = perfil['nombre'] as String?;
        });
      }
    } catch (e) {
      //en caso no da osea si falla el menu no saldra sin opciones
    }
  }

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) {
      return 'Buenos días';
    } else if (hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.teal,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  'https://res.cloudinary.com/dfej71ufs/image/upload/v1764488154/neumatik_banner_yh8c44.jpg',
                ),
                opacity: 0.3,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '${_obtenerSaludo()}, ${_nombreUsuario ?? ''}',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
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
          //para q se puedan visualizar las publicaciones
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
            onTap: () async {
              await _authService.logout();
              if (mounted)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

//un widget para el diseño de cada tarjeta de autoparte
class AutoparteCard extends StatelessWidget {
  final PublicacionAutoparte publicacion;

  const AutoparteCard({Key? key, required this.publicacion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      clipBehavior: Clip.antiAlias, //ajuste a bordes redondeados
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //imagen d autoparte
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
          //contenido de texto
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
                  'S/ ${publicacion.precio.toStringAsFixed(2)}',
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
