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
//4.1 crear el método de validación
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  //4.2 crear las variables de error message
  String? emailError;
  String? passwordError;
  
  //4.3 validadores 
  bool isValidEmail(String email) {
    // Expresión regular para validar el formato del correo electrónico
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$'); // Expresión regular para validar el formato del correo electrónico
    return re.hasMatch(email);
  }
  bool isValidPassword(String password) {
    // Validar que la contraseña tenga al menos 6 caracteres
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',);
    return re.hasMatch(password);
  }
  //4.4 crear el metodo de validar accion al boton de login
  void login() {
    //4.5 antes de lo que escriba el usuario quitar el espacio en blanco al inicio y al final
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    //4.6 validar que el correo y la contraseña sean correctos
    final eError = isValidEmail(email) ? null : 'Invalid email format';
    final pError = isValidPassword(password) ? null : 'Invalid password';

    setState(() {
      emailError = eError;
      passwordError = pError;  
    });

    //4.7 si el correo y la contraseña son correctos, mostrar la animación de success
    FocusScope.of(context).unfocus(); // quitar el foco de los campos de texto
    _typpingDebouncer?.cancel(); // cancelar el timer pendiente
    _isHandsUp?.change(false);
    _isChecking?.change(false);
    _numLook?.value = 50.0; // mirar al frente
    //4.8 activar triggers de animación de éxito o falla según corresponda
    if (eError == null && pError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }
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
      body: SingleChildScrollView(// SingleChildScrollView para que la pantalla sea scrollable y no se corte el contenido
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
                //4.9 agregar controladores y listeners de foco y cambios de texto
                controller: _emailCtrl,
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
                  errorText: emailError, // 4.10 mostrar el mensaje de error si existe
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
                controller: _passCtrl,
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
                  errorText: passwordError,
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
              SizedBox(
                width: size.width,
                child: const Text(
                  'forgot password?',
                  textAlign: TextAlign.right,// alinear a la derecha
                  style: TextStyle(decoration: TextDecoration.underline,color: Colors.indigoAccent),// subrayar el texto
                )
              ), 
              const SizedBox(height: 20),
              // botón de inicio de sesión
              MaterialButton(
                onPressed: login,
                color: const Color.fromARGB(255, 108, 17, 178),
                minWidth: size.width,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              // boton de registro
              const SizedBox(height: 20),
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Don\'t have an account?'),
                    SizedBox(width: 5),
                    Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        decoration: TextDecoration.underline,// subrayar el texto
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              // botón de registro
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
   // _controller?.dispose();// liberar rlos controladores de animación
    _typpingDebouncer?.cancel(); // cancelar el timer pendiente
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}