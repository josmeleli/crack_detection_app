import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/pages/edit_profile_page.dart';
import 'package:flutter_application_1/widgets/text_input.dart'; // Importar la página de edición de perfil

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _diametroController = TextEditingController();

  Future<Map<String, dynamic>> _getUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final userData = userDoc.data() as Map<String, dynamic>;
    final name = userData['name'] as String;
    final phone = userData['phone'] as String;
    final email = userData['email'] as String;
    final imageUrl = userData['image_url'] as String?;
    final diametroEnMm = userData['diametroEnMm'] as double? ?? 66.00;

    _diametroController.text = diametroEnMm.toString();

    return {
      'name': name,
      'phone': phone,
      'email': email,
      'diametroEnMm': diametroEnMm,
      'image_url': imageUrl ?? ''
    };
  }

  @override
  void dispose() {
    _diametroController.dispose();
    super.dispose();
  }

void _showEditDiametroDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Red Circle Diameter in mm',
          style: TextStyle(
            fontSize: 16, // Ajusta el tamaño de la fuente según sea necesario
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This value represents the actual diameter of the red circle in millimeters and will be used as a reference to calculate the maximum width of the cracks in the image.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10), // Espacio entre el texto y el input
            textInput(
              controller: _diametroController,
              hint: 'Diameter in mm',
              icon: Icons.straighten,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  height: 40, // Ajusta la altura según sea necesario
                  child: ButtonWidget(
                    btnText: 'Close',
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icons.cancel,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Espacio entre los botones
              Expanded(
                child: SizedBox(
                  height: 40, // Ajusta la altura según sea necesario
                  child: ButtonWidget(
                    btnText: 'Save',
                    onClick: () async {
                      final newDiametro = double.parse(_diametroController.text);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({'diametroEnMm': newDiametro});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cambios guardados')),
                      );

                      setState(() {
                        // Actualizar el estado de ProfilePage
                      });

                      Navigator.of(context).pop();
                    },
                    icon: Icons.save,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
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
            final userDiametroEnMm = userData['diametroEnMm']!;

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
                              leading:
                                  Icon(Icons.phone, color: Colors.grey[800]),
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
                              leading:
                                  Icon(Icons.email, color: Colors.grey[800]),
                              title: Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(Icons.straighten,
                                  color: Colors.grey[800]),
                              title: Text(
                                userDiametroEnMm.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                              trailing: Text(
                                'Editable',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ), // Anotación de texto // Icono de ">"
                              onTap: _showEditDiametroDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      btnText: 'Edit Profile',
                      onClick: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(userData: {
                              'name': userName,
                              'phone': userPhone,
                              'email': userEmail,
                              'image_url': userImageUrl,
                            }),
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
                      btnText: 'Logout',
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
      ),
    );
  }
}
