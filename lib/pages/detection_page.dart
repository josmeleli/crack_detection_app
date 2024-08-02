import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Detectar',
      ),
      body: Center(
        child: Text('Aquí van las detecciones.'),
      ),
    );
  }
}
