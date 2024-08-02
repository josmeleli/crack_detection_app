import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Instrucciones',
      ),
      body: Center(
        child: Text('Aquí van las instrucciones.'),
      ),
    );
  }
}
