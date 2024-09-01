import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'edit_profile_page.dart'; // Importar la página de edición de perfil

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, String>> _getUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final userData = userDoc.data() as Map<String, dynamic>;
    final name = userData['name'] as String;
    final phone = userData['phone'] as String;
    final email = userData['email'] as String;
    final imageUrl = userData['image_url'] as String?;

    return {
      'name': name,
      'phone': phone,
      'email': email,
      'image_url': imageUrl ?? ''
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Perfil',
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar los datos del usuario.'));
          }

          final userData = snapshot.data!;
          final userName = userData['name']!;
          final userPhone = userData['phone']!;
          final userEmail = userData['email']!;
          final userImageUrl = userData['image_url']!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[350], // Fondo blanco
                    backgroundImage: userImageUrl.isNotEmpty
                        ? NetworkImage(userImageUrl)
                        : null,
                    child: userImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 70,
                            color: Colors
                                .grey.shade800, // Icono de color gris oscuro
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.grey[800]),
                            title: Text(
                              userPhone,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(Icons.email, color: Colors.grey[800]),
                            title: Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ButtonWidget(
                    btnText: 'Editar Perfil',
                    onClick: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(userData: userData),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                    icon: Icons.edit, // Icono opcional
                  ),
                  const SizedBox(height: 10),
                  ButtonWidget(
                    btnText: 'Cerrar Sesión',
                    onClick: () {
                      // Acción de cerrar sesión
                      FirebaseAuth.instance.signOut();
                    },
                    icon: Icons.logout, // Icono opcional
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
