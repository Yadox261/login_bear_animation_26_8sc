import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true; // para ocultar la contraseña
  //1.1 crear el cerebro de animaciones
  StateMachineController? _controller; //para controlar las animación del oso
  //SMI para controlar la animación del oso
  SMIBool? _isHandsUp; //para controlar la animación de levantar las manos
  SMIBool? _isChecking; //para controlar la animación de revisar el correo electrónico
  SMITrigger? _trigSuccess; //para controlar la animación de éxito
  SMITrigger? _trigFail; //para controlar la animación de falla

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; //para obtener el tamaño de la pantalla
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox( 
                width: size.width,
                height: 200,
                child: RiveAnimation.asset('assets/login-bear.riv',
                //1.2 agregar el controlador de animación del oso
                stateMachines: ['Login Machine'], //para controlar la animación del oso
                //1.3 agregar el controlador de animación del oso
                onInit: (artboard) {
                  _controller = StateMachineController.fromArtboard(artboard, 'Login Machine'); //para controlar la animación del oso
                  if (_controller != null) {
                    artboard.addController(_controller!); //para agregar el controlador de animación del oso
                    _isHandsUp = _controller!.findSMI('isHandsUp'); //para controlar la animación de levantar las manos
                    _isChecking = _controller!.findSMI('isChecking'); //para controlar la animación de revisar el correo electrónico
                    _trigSuccess = _controller!.findSMI('trigSuccess'); //para controlar la animación de éxito
                    _trigFail = _controller!.findSMI('trigFail'); //para controlar la animación de falla
                  }
                },
                ), // es para mostrar la animación del oso en la pantalla de inicio de sesión
              ),
              const SizedBox(height: 20), //campo de texto para el correo
              TextField(
                onTap: () {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);
                },
                onChanged: (value) {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);
                },
                keyboardType: TextInputType.emailAddress, //para que el teclado en el campo de texto de correo electrónico
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // para redondear los bordes del campo de texto
                  ),
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField( //campo de texto para la contraseña
                onTap: () {
                  _isChecking?.change(false);
                  _isHandsUp?.change(true);
                },
                onChanged: (value) {
                  _isChecking?.change(false);
                  _isHandsUp?.change(true);
                },
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure; //para ocultar o mostrar la contraseña
                      });
                    },
                    icon: const Icon(Icons.visibility, color: Colors.grey), //para mostrar la contraseña y cambiar el icono de visibilidad
                  ),  
                ), 
              ),
              const SizedBox(height: 20), // Tamaño del espacio entre el campo de texto y el botón de inicio de sesión
              ElevatedButton(onPressed: () {}, child: const Text('Login')), //botón de inicio de sesión
            ],
          ),
        ),
      ),
    );
  }
}