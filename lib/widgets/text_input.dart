import 'package:flutter/material.dart';

Widget textInput({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  String? Function(String?)? validator, // Agrega este parámetro opcional
  bool obscureText = false,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
    ),
    padding: const EdgeInsets.only(left: 10),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        prefixIcon: Icon(icon),
      ),
      validator: validator, // Agrega el validador aquí
      obscureText: obscureText,
    ),
  );
}