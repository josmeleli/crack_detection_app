import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/loading_dialog.dart';
import 'package:flutter_application_1/widgets/text_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final Map<String, String> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  File? _imageFile;
  String? _currentImageUrl;
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _currentImageUrl = widget.userData['image_url'];
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteCurrentImage() async {
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      try {
        final storageRef =
            FirebaseStorage.instance.refFromURL(_currentImageUrl!);
        await storageRef.delete();
        setState(() {
          _currentImageUrl = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar la imagen: $e')),
        );
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      // Verificar si hay cambios en los datos del usuario o si se ha agregado una nueva imagen
      bool hasChanges = _nameController.text != widget.userData['name'] ||
          _phoneController.text != widget.userData['phone'] ||
          _imageFile != null ||
          _newPasswordController.text.isNotEmpty;

      if (!hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay cambios para actualizar')),
        );
        return;
      }

      LoadingDialog.showLoadingDialog(
          context, 'Actualizando...'); // Mostrar el diálogo de carga

      String? imageUrl;
      if (_imageFile != null) {
        await _deleteCurrentImage(); // Delete the current image if a new one is being uploaded
        try {
          final String imageName =
              _uuid.v4(); // Generate a UUID for the image name
          final storageRef = FirebaseStorage.instance.ref().child(
              'users/${FirebaseAuth.instance.currentUser!.uid}/$imageName.jpg');
          await storageRef.putFile(_imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          LoadingDialog.hideLoadingDialog(
              context); // Ocultar el diálogo de carga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: $e')),
          );
          return;
        }
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          if (imageUrl != null) 'image_url': imageUrl,
        });

        if (_newPasswordController.text.isNotEmpty) {
          await _changePassword();
        }

        LoadingDialog.hideLoadingDialog(context); // Ocultar el diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado exitosamente')),
        );

        Navigator.of(context).pop(true); // Return true to indicate success
      } catch (e) {
        LoadingDialog.hideLoadingDialog(context); // Ocultar el diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    try {
      User user = FirebaseAuth.instance.currentUser!;
      String email = user.email!;

      // Reauthenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(_newPasswordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Editar Perfil',
        showLogoutButton: false,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[350],  // Fondo blanco
                        backgroundImage: _imageFile != null
                            ? FileImage(
                                _imageFile!) // Imagen del archivo local si está disponible
                            : (_currentImageUrl != null &&
                                    _currentImageUrl!.isNotEmpty
                                ? NetworkImage(
                                    _currentImageUrl!) // Imagen de la URL si está disponible y no está vacía
                                : null), // No se establece imagen de fondo si no hay imagen local ni URL válida
                        child: _imageFile == null &&
                                (_currentImageUrl == null ||
                                    _currentImageUrl!.isEmpty)
                            ? Icon(Icons.add_a_photo,
                                size: 70,
                                color: Colors.grey[
                                    800]) // Icono solo si no hay imagen de fondo
                            : null,
                      ),
                    ),
                    if (_currentImageUrl != null &&
                        _currentImageUrl!.isNotEmpty)
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteCurrentImage();
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({'image_url': FieldValue.delete()});
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                textInput(
                  controller: _nameController,
                  hint: 'Nombre',
                  icon: Icons.person,
                ),
                textInput(
                  controller: _phoneController,
                  hint: 'Teléfono',
                  icon: Icons.phone,
                ),
                textInput(
                  controller: _currentPasswordController,
                  hint: 'Contraseña Actual',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                textInput(
                  controller: _newPasswordController,
                  hint: 'Nueva Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                textInput(
                  controller: _confirmPasswordController,
                  hint: 'Confirmar Nueva Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                  btnText: 'Guardar Cambios',
                  onClick: () async {
                    if (_formKey.currentState!.validate()) {
                      // Reauthenticate the user with the current password
                      if (_currentPasswordController.text.isNotEmpty) {
                        try {
                          User user = FirebaseAuth.instance.currentUser!;
                          String email = user.email!;

                          AuthCredential credential =
                              EmailAuthProvider.credential(
                            email: email,
                            password: _currentPasswordController.text,
                          );

                          await user.reauthenticateWithCredential(credential);

                          // Si la reautenticación es exitosa, verificar si se ingresó una nueva contraseña
                          if (_newPasswordController.text.isNotEmpty) {
                            if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Las contraseñas no coinciden')),
                              );
                              return;
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Contraseña actual incorrecta')),
                          );
                          return;
                        }
                      }

                      await _updateUserData();
                    }
                  },
                  icon: Icons.save, // Icono opcional
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
