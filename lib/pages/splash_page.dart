import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/authentication/authentication_wrapper.dart';
import 'package:flutter_application_1/utils/color.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const AuthenticationWrapper()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter),
        ),
        child: Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.asset('assets/images/logo-bg.png'),
          ),
        ),
      ),
    );
  }
}