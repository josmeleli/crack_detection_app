import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Resultados',
      ),
      body: Center(
        child: Text('Aquí van los resultados.'),
      ),
    );
  }
}