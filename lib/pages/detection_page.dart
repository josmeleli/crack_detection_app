import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

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
                      borderRadius: BorderRadius.circular(16.0), // Bordes redondeados
                      child: Container(
                        width: containerWidth, // Hacer el contenedor más pequeño
                        height: containerWidth, // Hacer el contenedor cuadrado
                        color: const Color(0xFFF4F4F4), // Color ahuesado
                        child: const Center(
                          child: Text('Imagen aquí'),
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
                  onClick: () {
                    // Lógica para abrir la cámara
                  },
                  btnText: 'Abrir Cámara',
                  icon: Icons.camera_alt,
                ),
              ),
              Container(
                width: containerWidth,
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ButtonWidget(
                  onClick: () {
                    // Lógica para subir una imagen
                  },
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