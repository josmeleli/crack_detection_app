import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/service/authentication_service.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/validation/input_validation.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/header_container.dart';
import 'package:flutter_application_1/widgets/text_input.dart';
import '../widgets/loading_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_1/exception/auth_exception_handler.dart';

class RegPage extends StatefulWidget {
  final void Function() onPressed;
  const RegPage({super.key, required this.onPressed});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void handleSignUp() {
    LoadingDialog.showLoadingDialog(context, 'Registrando...');
    AuthenticationService()
        .signUpWithEmailAndPassword(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
      confirmPassword: _confirmPassword.text,
    )
        .then((status) {
      LoadingDialog.hideLoadingDialog(context);
      if (status == AuthResultStatus.successful) {
        Fluttertoast.showToast(msg: "Registro exitoso");
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        Fluttertoast.showToast(msg: errorMsg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: <Widget>[
                const HeaderContainer("Registrarse"),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      textInput(controller: _name ,hint: "Nombre Completo", icon: Icons.person, validator: nameValidator,),
                      textInput(controller: _email ,hint: "Correo", icon: Icons.email, validator: emailValidator, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))]),
                      textInput(controller: _phone ,hint: "Teléfono", icon: Icons.call, validator: phoneValidator, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)]),
                      textInput(controller: _password ,hint: "Contraseña", icon: Icons.vpn_key, validator: passwordValidator, obscureText: true),
                      textInput(controller: _confirmPassword,hint: "Confirmar Contraseña", icon: Icons.vpn_key, validator: (text) => confirmPasswordValidator(text, _password.text), obscureText: true),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        btnText: 'Registrar',
                        onClick: () {
                          if (_formKey.currentState!.validate()) {
                            handleSignUp();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: "¿Ya lo recuerdas?",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: " Iniciar Sesión",
                            style: TextStyle(color: primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onPressed,
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
