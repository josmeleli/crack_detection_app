import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart'; // Importar servicios para el portapapeles
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _showFullAddress = false;

  void _toggleAddressVisibility() {
    setState(() {
      _showFullAddress = !_showFullAddress;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dirección copiada')),
    );
  }

  Future<void> _showImageDialog(BuildContext context, String imageUrl,
      String convertedImageUrl, String nivelDeRiesgo) async {
    List<String> riskMessages;
    Color riskColor;
    switch (nivelDeRiesgo) {
      case 'Bajo':
        riskMessages = [
          'Observe these cracks occasionally to ensure they do not enlarge.',
          'If the crack is on an exterior wall, consider using a sealant to prevent moisture damage.'
        ];
        riskColor = riskLowColor;
        break;
      case 'Moderado':
        riskMessages = [
          'It is advisable for a professional to inspect the cracks to understand the cause and determine if any repairs are needed.',
          'Monitor these cracks monthly to see if they are growing.'
        ];
        riskColor = riskModerateColor;
        break;
      case 'Alto':
        riskMessages = [
          'Call an expert as soon as possible to assess the situation and determine the necessary repairs.',
          'Avoid using or putting weight on the affected area until a professional confirms it is safe.'
        ];
        riskColor = riskHighColor;
        break;
      default:
        riskMessages = [];
        riskColor = riskDefaultColor;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Risk level: $nivelDeRiesgo',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300, // Ajusta la altura según sea necesario
                  child: PageView(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          convertedImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 200);
                          },
                        ),
                      ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Recommendations:\n',
                        style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: riskMessages.map((message) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth *
                          0.4, // Ajusta el ancho del botón al 30% del ancho disponible
                      height: 40, // Ajusta la altura del botón
                      child: ButtonWidget(
                        btnText: 'Close',
                        onClick: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icons.cancel,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteResult(BuildContext context, String docId,
      String imageUrl, String convertedImageUrl) async {
    try {
      // Eliminar el documento de Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('results')
          .doc(docId)
          .delete();

      // Eliminar la imagen de Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(
        imageUrl,
      );
      await storageRef.delete();

      // Eliminar la imagen convertida de Firebase Storage
      final convertedStorageRef =
          FirebaseStorage.instance.refFromURL(convertedImageUrl);
      await convertedStorageRef.delete();

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

  Future<Map<String, String>> _getUserData() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final userData = userDoc.data() as Map<String, dynamic>;
    final name = userData['name'] as String;
    final phone = userData['phone'] as String;

    return {'name': name, 'phone': phone};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Results',
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return const Center(
                child: Text('Error al cargar los datos del usuario.'));
          }

          final userData = userSnapshot.data!;
          final userName = userData['name']!;
          final userPhone = userData['phone']!;

          return Column(
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
                        const Text('Low'),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              riskModerateColor, // Usar el color amarillo oscuro
                          radius: 10,
                        ),
                        const SizedBox(width: 5),
                        const Text('Moderate'),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: riskHighColor, // Usar el color rojo
                          radius: 10,
                        ),
                        const SizedBox(width: 5),
                        const Text('High'),
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
                      return const Center(
                          child: Text('No hay resultados disponibles.'));
                    }

                    return ListView.builder(
  itemCount: snapshot.data!.docs.length,
  itemBuilder: (context, index) {
    final result = snapshot.data!.docs[index];
    final docId = result.id;
    final imageUrl = result['image_url'];
    final maxCrackWidth = result['max_crack_width'];
    final nivelDeRiesgo = result['nivel_de_riesgo'];
    final address = result['direccion']; // Obtener la dirección
    final convertedImageUrl = result['converted_image_url']; // Obtener la URL de la imagen convertida

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
          _showImageDialog(context, imageUrl, convertedImageUrl, nivelDeRiesgo);
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: riskColor,
                  width: 5.0,
                ),
              ),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 65,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteResult(context, docId, imageUrl, convertedImageUrl);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Risk Level: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            TextSpan(
                              text: nivelDeRiesgo,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        'Crack Width: $maxCrackWidth mm',
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 1.4,
                    height: 1, // Ajustar la altura del Divider
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, bottom: 16.0, top: 8.0), // Ajustar padding
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
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[800]),
                                  const SizedBox(width: 5),
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.grey[800]),
                                  const SizedBox(width: 5),
                                  Text(
                                    userPhone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey[800]),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _toggleAddressVisibility,
                                      onLongPress: () => _copyToClipboard(address),
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[800],
                                        ),
                                        overflow: _showFullAddress ? TextOverflow.visible : TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.format_list_numbered, size: 16, color: Colors.grey[800]),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Result N° ${snapshot.data!.docs.length - index}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
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
      ),
    );
  },
);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
