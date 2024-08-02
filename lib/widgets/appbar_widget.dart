import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // Cambia el color del título aquí
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: orangeColors,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white, // Cambia el color del icono aquí
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut(); // Cierra la sesión
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}