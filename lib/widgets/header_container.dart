import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class HeaderContainer extends StatelessWidget {
  var text = "Iniciar Sesión";
  HeaderContainer(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [orangeColors, orangeLightColors],
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 40,
            right: 20,
              child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          )),
          Center(
            child: Image.asset('assets/images/logo.png'),
          ),
        ],
      ),
    );
  }
}
