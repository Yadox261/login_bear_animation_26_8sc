import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true; // para ocultar la contraseña

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
                child: RiveAnimation.asset('assets/login-bear.riv'), // es para mostrar la animación del oso en la pantalla de inicio de sesión
              ),
              const SizedBox(height: 20), //campo de texto para el correo
              TextField(
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
                obscureText: _obscure,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(onPressed: () {
                    setState(() {
                      _obscure = !_obscure; //para mostrar la contraseña
                    });
                  }, icon: const Icon(Icons.visibility, color: Colors.grey,), //para mostrar la contraseña y cambiar el icono de visibilidad

                ),  
                ), 
              ),/*
              const SizedBox(height: 20), // Tamaño del espacio entre el campo de texto y el botón de inicio de sesión
              ElevatedButton(onPressed: () {}, child: const Text('Login')), //botón de inicio de sesión*/
            ],
          ),
        ),
      ),
    );
  }
}