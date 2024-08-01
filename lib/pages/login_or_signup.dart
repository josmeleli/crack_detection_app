import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_application_1/pages/regi_page.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});

  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool islogin = true;

  void togglePage(){
    setState(() {
      islogin = !islogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(islogin){
      return LoginPage(onPressed: togglePage);
    } else {
      return RegPage(onPressed: togglePage);
    }
    
  }
}