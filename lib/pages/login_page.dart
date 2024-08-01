import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/header_container.dart';
import 'package:flutter_application_1/widgets/loading_dialog.dart';
import 'package:flutter_application_1/widgets/text_input.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_1/validation/input_validation.dart';

import '../exception/auth_exception_handler.dart';
import '../service/authentication_service.dart';

class LoginPage extends StatefulWidget {
  final void Function() onPressed;

  const LoginPage({super.key, required this.onPressed});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void handleLogin(){

    LoadingDialog.showLoadingDialog(context, 'Iniciando sesión...');

    AuthenticationService()
        .loginWithEmailAndPassword(
      email: _email.text,
      password: _password.text,
    )
        .then((status) {
          LoadingDialog.hideLoadingDialog(context);
      if (status == AuthResultStatus.successful) {
        Fluttertoast.showToast(msg: "Inicio de sesión exitoso");
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        Fluttertoast.showToast(msg: errorMsg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
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
                      textInput(
                        controller: _email,
                        hint: "Correo",
                        icon: Icons.email,
                        validator: emailValidator,
                      ),
                      textInput(
                        controller: _password,
                        hint: "Contraseña",
                        icon: Icons.vpn_key,
                        validator: passwordValidator,
                        obscureText: true,
                      ),
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
                                handleLogin();
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
                              ..onTap = widget.onPressed,
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

}
