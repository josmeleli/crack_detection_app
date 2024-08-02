import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_or_signup.dart';
import 'package:flutter_application_1/navigation_menu.dart';



class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          } else {
            if(snapshot.hasData){
              return const NavigationMenu();
            } else {
              return const LoginAndSignUp();
            }
            
          }
        },
      ),
    );
  }
}
 
 