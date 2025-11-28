import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// Importamos el modelo UsuarioAutenticado para el tipado, ya que el servicio lo devuelve.
import '../models/usuario_autenticado.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String correo = _correoController.text.trim();
      final String contrasena = _contrasenaController.text;

      try {
        // Tipamos explícitamente el resultado para asegurar el uso del modelo UsuarioAutenticado.
        final UsuarioAutenticado usuarioAutenticado = await _authService.loginUser(
          correo: correo, 
          contrasena: contrasena,
        );

        if (mounted) {
          // FIX: Accedemos a la propiedad 'nombre' a través del objeto anidado 'user'
          // Utilizamos nombreCompleto que ya está definido en el modelo Usuario.
          final userName = usuarioAutenticado.user.nombreCompleto; 

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Sesión iniciada con éxito. Bienvenido, $userName!',
              ),
              backgroundColor: Colors.teal,
            ),
          );

          // Redirigir al Home y eliminar el Login de la pila de navegación
          // Se asume que '/home' es la ruta principal.
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          // Captura errores lanzados por el AuthService (ej. Credenciales inválidas o conexión)
          final errorMessage = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al iniciar sesión: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Navega a la pantalla de registro
  void _navigateToRegister() {
    // Se asume que '/register' es la ruta de registro.
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Añadimos un AppBar para consistencia de diseño
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Título/Logo
                  const Text(
                    'Bienvenido a Neumatik',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 40),

                  // Campo Correo
                  TextFormField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'El correo es obligatorio.';
                      if (!value.contains('@'))
                        return 'Ingresa un correo válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña
                  TextFormField(
                    controller: _contrasenaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.teal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                    ),
                    validator: (value) => value == null || value.length < 6
                        ? 'La contraseña debe tener al menos 6 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 30),

                  // Botón de Inicio de Sesión
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 15),

                  // Enlace a Registro
                  TextButton(
                    onPressed: _navigateToRegister,
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}