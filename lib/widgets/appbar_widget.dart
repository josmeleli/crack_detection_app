import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogoutButton; 
  final bool automaticallyImplyLeading; 

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLogoutButton = true, 
    this.automaticallyImplyLeading = false, 
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, 
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading, 
      backgroundColor: primaryColor,
      iconTheme: const IconThemeData(
        color: Colors.white, 
      ),
      actions: showLogoutButton
          ? [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white, 
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut(); 
                },
              ),
            ]
          : null, 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
