import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../exception/auth_exception_handler.dart';

class AuthenticationService{
  late AuthResultStatus status;

  // Sign in with email and password
  Future<AuthResultStatus> loginWithEmailAndPassword({
    required String email, 
    required String password,
    }) async {
    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password,
        );
      if (authResult.user != null) {
        status = AuthResultStatus.successful;
      }else{
        status = AuthResultStatus.undefined;
      }
      return status;
      
    } catch(msg){
      status = AuthExceptionHandler.handleException(msg);
    }
    return status;
  }

  // Sign out
  Future<AuthResultStatus> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    }) async {
    try {
      final UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password,
        );
      if (authResult.user != null) {
        _saveUserDetails(
          name: name,
          email: email,
          phone: phone,
          userId: authResult.user!.uid,
        );
        status = AuthResultStatus.successful;
      }else{
        status = AuthResultStatus.undefined;
      }
      return status;
      
    } catch(msg){
      status = AuthExceptionHandler.handleException(msg);
    }
    return status;
  }

  void _saveUserDetails({required String name, email, phone, userId}){
    // Save user data to Firestore
    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'userId': userId,
    });
  }
}