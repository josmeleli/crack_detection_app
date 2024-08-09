import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  DetectionPageState createState() => DetectionPageState();
}

class DetectionPageState extends State<DetectionPage> {
  XFile? _image;

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
      // En Android, revisa los permisos de fotos y almacenamiento
      return await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted;
    } else if (Platform.isIOS) {
      // En iOS, solo revisa el permiso de fotos
      return await Permission.photos.request().isGranted;
    }
    return false;
  }

  Future<void> _openCamera() async {
    // Solicitar permisos de cámara
    if (await Permission.camera.request().isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null && mounted) {
        setState(() {
          _image = image;
        });
      }
    } else if (mounted) {
      // Manejar el caso en que los permisos no son concedidos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
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
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(16.0), // Bordes redondeados
                      child: Container(
                        width:
                            containerWidth, // Hacer el contenedor más pequeño
                        height: containerWidth, // Hacer el contenedor cuadrado
                        color: const Color(0xFFF4F4F4), // Color ahuesado
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
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: () {
                    // Lógica para detectar
                  },
                  btnText: 'Detectar',
                  icon: Icons.broken_image,
                ),
              ),
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: _openCamera,
                  btnText: 'Abrir Cámara',
                  icon: Icons.camera_alt,
                ),
              ),
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
}
