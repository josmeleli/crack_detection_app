import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: 'Perfil',
      ),
      body: Center(
        child: Text('Aquí va el perfil.'),
      ),
    );
  }
}