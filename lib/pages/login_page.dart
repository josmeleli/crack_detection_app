import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/forgot_pw_page.dart';
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

  void handleLogin() {
    LoadingDialog.showLoadingDialog(context, 'Logging in...');

    AuthenticationService()
        .loginWithEmailAndPassword(
      email: _email.text,
      password: _password.text,
    )
        .then((status) {
      LoadingDialog.hideLoadingDialog(context);
      if (status == AuthResultStatus.successful) {
        Fluttertoast.showToast(msg: "Login successful");
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
          child: Column(
            children: <Widget>[
              const HeaderContainer("Login"),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Column(
                  children: <Widget>[
                    textInput(
                      controller: _email,
                      hint: "Email",
                      icon: Icons.email,
                      validator: emailValidator,
                    ),
                    textInput(
                      controller: _password,
                      hint: "Password",
                      icon: Icons.vpn_key,
                      validator: passwordValidator,
                      obscureText: true,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Forget your password?",
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    ButtonWidget(
                      onClick: () {
                        if (_formKey.currentState!.validate()) {
                          handleLogin();
                        }
                      },
                      btnText: 'Login',
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: "Don't have an account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: " Sign up",
                          style: TextStyle(color: primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onPressed,
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
