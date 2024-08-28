import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Resultados',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('results')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay resultados disponibles.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final result = snapshot.data!.docs[index];
              final imageUrl = result['image_url'];
              final maxCrackWidth = result['max_crack_width'];
              final nivelDeRiesgo = result['nivel_de_riesgo'];

              Color riskColor;
              switch (nivelDeRiesgo) {
                case 'Bajo':
                  riskColor = Colors.green;
                  break;
                case 'Moderado':
                  riskColor = Colors.yellow;
                  break;
                case 'Alto':
                  riskColor = Colors.red;
                  break;
                default:
                  riskColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text('Ancho de grieta: $maxCrackWidth mm'),
                  subtitle: Text('Nivel de riesgo: $nivelDeRiesgo'),
                  tileColor: riskColor.withOpacity(0.2),
                  textColor: riskColor,
                ),
              );
            },
          );
        },
      ),
    );
  }
}