import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [orangeColors, orangeLightColors],
                    end: Alignment.bottomCenter,
                    begin: Alignment.topCenter),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(100)),
              ),
              child: Center(
                child: Image.asset('images/logo.png'),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: <Widget>[
                    _textInput(hint: "Correo", icon: Icons.email),
                    _textInput(hint: "Contraseña", icon: Icons.vpn_key),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Olvidaste tu contraseña?",
                      ),
                    ),
                    Container(
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [orangeColors, orangeLightColors],
                                end: Alignment.centerLeft,
                                begin: Alignment.centerRight),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100))),
                        alignment: Alignment.center,
                        child: Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textInput({controller, hint, icon}) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding:
              EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
