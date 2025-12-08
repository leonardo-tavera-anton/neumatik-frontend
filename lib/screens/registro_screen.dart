import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import '../models/usuario_autenticado.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  //mismo controladores q coloco en todos lados
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  //funcion para enviar el formulario
  void _submitRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        //llama al servicio de auth para registrar
        final UsuarioAutenticado result = await _authService.registerUser(
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          correo: _correoController.text.trim(),
          contrasena: _contrasenaController.text,
          telefono: _telefonoController.text.trim(), //opcional
        );

        final Usuario newUser = result
            .user; //si todo sale bien se deberia mostrar este mensaje de exito supuestamente pero no funciona ahora lo veo

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Registro exitoso. ¡Bienvenido, ${newUser.nombreCompleto}!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          //redirige al home
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      } catch (e) {
        //si hay error lo muestra aqui
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Completa tus datos para empezar a vender y comprar autopartes.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 25),

              //campo nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'El nombre es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 15),

              //campo apellido
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'El apellido es obligatorio.'
                    : null,
              ),
              const SizedBox(height: 15),

              //campo correo
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio.';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Introduce un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              //campo contraseña
              TextFormField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña (mín. 6 caracteres)',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'La contraseña debe tener al menos 6 caracteres.'
                    : null,
              ),
              const SizedBox(height: 15),

              //campo telefono
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (Opcional)',
                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              //mensaje d error solo si hay
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              //boton registrar
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitRegistration,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_isLoading ? 'Registrando...' : 'Registrar Cuenta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              //volver al login
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); //vuelve a la pantalla de login una vez registrado
                },
                child: Text(
                  '¿Ya tienes cuenta? Inicia Sesión',
                  style: TextStyle(color: Colors.blueGrey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
