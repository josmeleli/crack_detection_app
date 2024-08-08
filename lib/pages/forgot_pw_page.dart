import 'package:flutter/material.dart';
import 'package:flutter_application_1/exception/auth_exception_handler.dart';
import 'package:flutter_application_1/service/authentication_service.dart';
import 'package:flutter_application_1/validation/input_validation.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/loading_dialog.dart';
import 'package:flutter_application_1/widgets/text_input.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void handleForgotPassword() {
    
    // Acción al hacer clic en el botón
    LoadingDialog.showLoadingDialog(context, 'Enviando correo...');
    AuthenticationService().forgotPassword(email: _email.text).then((status) {
      LoadingDialog.hideLoadingDialog(context);
      if (status == AuthResultStatus.successful) {
        Fluttertoast.showToast(
            msg: "Correo enviado, revisa tu bandeja de entrada");
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        Fluttertoast.showToast(msg: errorMsg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Cambiar contraseña',
        showLogoutButton: false,
        automaticallyImplyLeading: true,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              const Text(
                'Olvidé mi contraseña',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Por favor, ingrese su correo electrónico. Le enviaremos un enlace para restablecer su contraseña.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              textInput(
                controller: _email,
                hint: "Correo",
                icon: Icons.email,
                validator: emailValidator,
              ),
              const SizedBox(height: 20),
              ButtonWidget(
                btnText: 'Enviar',
                onClick: () {
                  if (_formKey.currentState!.validate()) {
                    handleForgotPassword();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
