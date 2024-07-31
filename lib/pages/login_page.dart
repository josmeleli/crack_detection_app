import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/regi_page.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/header_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: <Widget>[
              const HeaderContainer("Iniciar Sesión"),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      _textInput(
                        controller: _email,
                        hint: "Correo",
                        icon: Icons.email,
                        validator: emailValidator,
                      ),
                      _textInput(
                          controller: _password,
                          hint: "Contraseña",
                          icon: Icons.vpn_key,
                          validator: (text) {
                            if (text == null || text.trim().isEmpty) {
                              return 'La contraseña está vacía';
                            }
                            return null;
                          }, 
                          obscureText: true,),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        alignment: Alignment.centerRight,
                        child: const Text(
                          "Olvidaste tu contraseña?",
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ButtonWidget(
                            onClick: () {
                              if (_formKey.currentState!.validate()) {
                                print('validate is done');
                                
                              }
                            },
                            btnText: 'Iniciar Sesión',
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: "No tienes una cuenta?",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: " Registrate",
                            style: TextStyle(color: orangeColors),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const RegPage()));
                              },
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator, // Agrega este parámetro opcional
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          prefixIcon: Icon(icon),
        ),
        validator: validator, // Agrega el validador aquí
        obscureText: obscureText,
      ),
    );
  }
  String? emailValidator(String? text) {
  if (text == null || text.trim().isEmpty) {
    return 'El correo está vacío';
  }
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );
  if (!emailRegExp.hasMatch(text)) {
    return 'El correo no es válido';
  }
  return null;
}
}
