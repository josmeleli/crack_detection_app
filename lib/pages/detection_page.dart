import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/loading_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  DetectionPageState createState() => DetectionPageState();
}

class DetectionPageState extends State<DetectionPage> {
  XFile? _image;

  Future<void> _sendImageToAPI(BuildContext context) async {
    if (_image != null) {
      try {
        // Muestra el cuadro de diálogo de carga
        LoadingDialog.showLoadingDialog(context, 'Detectando...');

        // Obtén el usuario actual de Firebase
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.uid;

          // Subir la imagen a Firebase Storage
          final imageUrl = await _uploadImageToFirebaseStorage(userId, _image!);

          // Detectar el diámetro del círculo rojo
          final circleDiameter = await _detectCircleDiameter(_image!);

          if (circleDiameter != null) {
            // Prepara la imagen para el envío
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('http://10.0.2.2:8000/predict/')
            );

            request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

            var response = await request.send();

            if (response.statusCode == 200) {
              final responseData = await response.stream.bytesToString();
              final decodedData = json.decode(responseData);

              // Verifica que las claves existan y no sean nulas
              if (decodedData.containsKey('max_crack_width') && decodedData['max_crack_width'] != null) {
                double maxCrackWidth = decodedData['max_crack_width'];

                // Envía los resultados a Firestore
                await _sendResultsToFirestore(userId, maxCrackWidth, imageUrl);

                // Cierra el cuadro de diálogo de carga
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resultados enviados exitosamente')),
                );
              } else {
                // Cierra el cuadro de diálogo de carga
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Respuesta de la API inválida')),
                );
              }
            } else {
              // Cierra el cuadro de diálogo de carga
              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al procesar la imagen')),
              );
            }
          } else {
            // Cierra el cuadro de diálogo de carga
            Navigator.of(context).pop();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se detectó un círculo rojo en la imagen')),
            );
          }
        } else {
          // Cierra el cuadro de diálogo de carga
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no autenticado')),
          );
        }
      } catch (e) {
        // Cierra el cuadro de diálogo de carga
        Navigator.of(context).pop();

        print("Error al enviar la imagen: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar la imagen')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen')),
      );
    }
  }

  Future<int?> _detectCircleDiameter(XFile image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/detectar-circulos/')
      );

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        if (decodedData.containsKey('message') && decodedData['message'] != null) {
          final message = decodedData['message'];
          final regex = RegExp(r'(\d+)');
          final match = regex.firstMatch(message);
          if (match != null) {
            return int.parse(match.group(0)!);
          }
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print("Error al detectar el círculo rojo: $e");
      return null;
    }
  }

  Future<String> _uploadImageToFirebaseStorage(String userId, XFile image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/${image.name}');
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error al subir la imagen a Firebase Storage: $e");
      throw Exception('Error al subir la imagen a Firebase Storage');
    }
  }

  Future<void> _sendResultsToFirestore(String userId, double maxCrackWidth, String imageUrl) async {
    try {
      // Crea una nueva referencia de documento para almacenar los resultados
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('results')
          .add({
        'max_crack_width': maxCrackWidth,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(), // Añadir marca de tiempo
      });
    } catch (e) {
      print("Error al enviar los resultados a Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los resultados en Firestore')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double containerWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detectar',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Muestra la imagen seleccionada o un mensaje
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        width: containerWidth,
                        height: containerWidth,
                        color: const Color(0xFFF4F4F4),
                        child: _image == null
                            ? const Center(child: Text('Imagen aquí'))
                            : Image.file(
                                File(_image!.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
              // Botón para enviar la imagen a la API y procesar resultados
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: () => _sendImageToAPI(context),
                  btnText: 'Detectar',
                  icon: Icons.broken_image,
                ),
              ),
              // Botón para abrir la cámara
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: _openCamera,
                  btnText: 'Abrir Cámara',
                  icon: Icons.camera_alt,
                ),
              ),
              // Botón para subir la imagen desde la galería
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: _pickImage,
                  btnText: 'Subir Imagen',
                  icon: Icons.upload_file,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    if (await Permission.camera.request().isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        setState(() {
          _image = image;
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
    }
  }

  Future<void> _pickImage() async {
    final hasPermission = await _checkPermissions();

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        setState(() {
          _image = image;
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de acceso a imágenes denegado')),
      );
    }
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      return await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }
}