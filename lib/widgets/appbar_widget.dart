import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogoutButton; // Parámetro opcional
  final bool automaticallyImplyLeading; // Nuevo parámetro opcional

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLogoutButton = true, // Valor por defecto
    this.automaticallyImplyLeading = false, // Valor por defecto
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
      automaticallyImplyLeading: automaticallyImplyLeading, // Usar el nuevo parámetro
      backgroundColor: primaryColor,
      actions: showLogoutButton
          ? [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white, // Cambia el color del icono aquí
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); // Cierra la sesión
                },
              ),
            ]
          : null, // No mostrar acciones si showLogoutButton es false
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}