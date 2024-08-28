import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';


class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 200);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteResult(BuildContext context, String docId, String imageUrl) async {
    try {
      // Eliminar el documento de Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('results')
          .doc(docId)
          .delete();

      // Eliminar la imagen de Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resultado eliminado exitosamente')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el resultado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Resultados',
      ),
      body: Column(
        children: [
          // Lista horizontal con los puntos de colores
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: riskLowColor, // Usar el color verde
                      radius: 10,
                    ),
                    const SizedBox(width: 5),
                    const Text('Bajo'),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: riskModerateColor, // Usar el color amarillo oscuro
                      radius: 10,
                    ),
                    const SizedBox(width: 5),
                    const Text('Moderado'),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: riskHighColor, // Usar el color rojo
                      radius: 10,
                    ),
                    const SizedBox(width: 5),
                    const Text('Alto'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                    final docId = result.id;
                    final imageUrl = result['image_url'];
                    final maxCrackWidth = result['max_crack_width'];
                    final nivelDeRiesgo = result['nivel_de_riesgo'];

                    Color riskColor;
                    switch (nivelDeRiesgo) {
                      case 'Bajo':
                        riskColor = riskLowColor; // Usar el color verde
                        break;
                      case 'Moderado':
                        riskColor = riskModerateColor; // Usar el color amarillo oscuro
                        break;
                      case 'Alto':
                        riskColor = riskHighColor; // Usar el color rojo
                        break;
                      default:
                        riskColor = riskDefaultColor; // Usar el color gris
                    }

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          _showImageDialog(context, imageUrl);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 65,
                                  child: ListTile(
                                    trailing: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                      margin: const EdgeInsets.only(top: 15),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.grey[50], // button color
                                          child: InkWell(
                                            child: const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                )),
                                            onTap: () {
                                              _deleteResult(context, docId, imageUrl);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      'Ancho de grieta: $maxCrackWidth mm',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('Nivel de riesgo: $nivelDeRiesgo'),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    'Imagen:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Divider(
                                    thickness: 1.4,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0, bottom: 16.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(
                                          imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image, size: 80);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ancho de grieta: $maxCrackWidth mm',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Nivel de riesgo: $nivelDeRiesgo',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: riskColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}