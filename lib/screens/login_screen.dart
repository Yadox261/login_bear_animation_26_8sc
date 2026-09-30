import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importar el timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true; // para ocultar la contraseña

  //1.1 crear el cerebro de animaciones
  StateMachineController? _controller; // para controlar las animaciones del oso

  // SMI para controlar la animación del oso
  SMIBool? _isHandsUp; // levantar las manos
  SMIBool? _isChecking; // revisar el correo electrónico
  SMINumber? _numLook; // 3.2 mirar hacia los lados (es un número, no un trigger)

  //3.3 timer
  Timer? _typpingDebouncer; // espera después de dejar de escribir

  SMITrigger? _trigSuccess; // animación de éxito
  SMITrigger? _trigFail; // animación de falla

  //2.1 crear las variables de foco
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  //2.2 agregar los listeners de foco
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isHandsUp?.change(false);
        _isChecking?.change(true);
        //3.4 posición inicial de la mirada
        _numLook?.value = 50.0;
      } else {
        // al perder el foco el oso deja de revisar
        _isChecking?.change(false);
      }
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
      if (_passwordFocusNode.hasFocus) {
        _isChecking?.change(false);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // tamaño de la pantalla
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/login-bear.riv',
                  //1.2 agregar la state machine del oso
                  stateMachines: const ['Login Machine'],
                  //1.3 enlazar el controlador y los inputs
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    if (_controller != null) {
                      artboard.addController(_controller!);
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _isChecking = _controller!.findSMI('isChecking');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),
              // campo de texto para el correo
              TextField(
                focusNode: _emailFocusNode,
                onTap: () {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);
                },
                onChanged: (value) {
                  _isChecking?.change(true);
                  _isHandsUp?.change(false);

                  // el oso mira más hacia la derecha conforme escribes más
                  final look = (value.length / 80 * 100).clamp(0.0, 100.0);
                  _numLook?.value = look;

                  // 3.5 si dejas de escribir 3 segundos, el oso deja de revisar
                  //cancelar cualquier timer existente
                  _typpingDebouncer?.cancel();
                  _typpingDebouncer = Timer( Duration(seconds: 2), () {
                    //si se cierra la pantalla quita el timer
                    if (!mounted) return;
                    //mirada neutral y deja de revisar
                    _isChecking?.change(false);
                  });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              // campo de texto para la contraseña
              TextField(
                focusNode: _passwordFocusNode,
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
                        _obscure = !_obscure; // ocultar o mostrar la contraseña
                      });
                    },
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // botón de inicio de sesión
              ElevatedButton(
                onPressed: () {},
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _typpingDebouncer?.cancel(); // cancelar el timer pendiente
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}