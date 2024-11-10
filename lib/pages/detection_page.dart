import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';
import 'package:flutter_application_1/widgets/btn_widget.dart';
import 'package:flutter_application_1/widgets/loading_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  DetectionPageState createState() => DetectionPageState();
}

class DetectionPageState extends State<DetectionPage> {
  XFile? _image;
  double diametroEnMm = 66.00;

  // Definición de los niveles de riesgo
  final double riesgoBajoMax = 2.00;
  final double riesgoModeradoMax = 5.00;
  final double riesgoAltoMax = 15.00;

  @override
  void initState() {
    super.initState();
    _loadDiametroEnMm();
  }

  Future<void> _loadDiametroEnMm() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();


      // Obtener los datos del usuario como un mapa
      final userData = userDoc.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          // Cargar el diámetro del usuario si existe, de lo contrario, usa el valor predeterminado
          diametroEnMm = userData['diametroEnMm'] as double? ?? 66.00;
        });
      }
    } catch (e) {
      // Manejo de errores si es necesario
      print('Error al cargar el diámetro: $e');
    }
  }

  Future<void> _sendImageToAPI() async {
    if (_image != null) {
      try {
        print("Iniciando clasificación de imagen...");

        // Clasificar la imagen para verificar si hay grietas
        final crackDetected = await _classifyImage(_image!);
        print("Clasificación de la imagen: $crackDetected");

        if (crackDetected) {
          // Detectar el diámetro del círculo rojo
          final circleDiameter = await _detectCircleDiameter(_image!);
          print("Diámetro del círculo detectado: $circleDiameter");

          if (circleDiameter != null) {
            // Muestra el cuadro de diálogo de carga
            if (mounted) {
              LoadingDialog.showLoadingDialog(context, 'Detectando...');
            }

            // Obtén el usuario actual de Firebase
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final userId = user.uid;

              // Obtener la ubicación actual
              final position = await _determinePosition();
              print("Ubicación obtenida: ${position.latitude}, ${position.longitude}");
              final address = await _getAddressFromPosition(position);
              print("Dirección obtenida: $address");

              // Convertir XFile a File
              final file = File(_image!.path);

              // Subir la imagen a Firebase Storage
              final imageUrl = await _uploadImageToFirebaseStorage(userId, file);
              print("URL de la imagen subida: $imageUrl");

              // Prepara la imagen para el envío
              var request = http.MultipartRequest(
                  'POST', Uri.parse('https://r964z9v6-8000.brs.devtunnels.ms/predict/'));

              request.files
                  .add(await http.MultipartFile.fromPath('file', _image!.path));

              

              var response = await request.send();
              print("Respuesta de la API recibida: ${response.statusCode}");

              if (response.statusCode == 200) {
                final responseData = await response.stream.bytesToString();
                final decodedData = json.decode(responseData);
                print("Datos decodificados de la API: $decodedData");

                // Verifica que las claves existan y no sean nulas
                if (decodedData.containsKey('max_crack_width') &&
                    decodedData['max_crack_width'] != null) {
                  double maxCrackWidthPx = decodedData['max_crack_width'];

                  // Calcula el ancho de la grieta en milímetros
                  double maxCrackWidthMm =
                      maxCrackWidthPx * (diametroEnMm / circleDiameter);

                  // Determina el nivel de riesgo
                  String nivelDeRiesgo;
                  if (maxCrackWidthMm <= riesgoBajoMax) {
                    nivelDeRiesgo = "Bajo";
                  } else if (maxCrackWidthMm <= riesgoModeradoMax) {
                    nivelDeRiesgo = "Moderado";
                  } else {
                    nivelDeRiesgo = "Alto";
                  }

                  // Convertir la imagen en base64 a archivo de imagen
                  if (decodedData.containsKey('max_width_image') &&
                      decodedData['max_width_image'] != null) {
                    final base64Image = decodedData['max_width_image'];
                    final imageFile = await _convertBase64ToFile(base64Image);

                    // Subir la imagen convertida a Firebase Storage
                    final convertedImageUrl = await _uploadImageToFirebaseStorage(userId, imageFile);

                    // Envía los resultados a Firestore
                    await _sendResultsToFirestore(
                        userId, maxCrackWidthMm, imageUrl, nivelDeRiesgo, address, convertedImageUrl);

                    // Cierra el cuadro de diálogo de carga
                    if (mounted) {
                      Navigator.of(context).pop();
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Resultados enviados exitosamente')),
                      );
                    }
                  } else {
                    // Cierra el cuadro de diálogo de carga
                    if (mounted) {
                      Navigator.of(context).pop();
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Respuesta de la API inválida')),
                      );
                    }
                  }
                } else {
                  // Cierra el cuadro de diálogo de carga
                  if (mounted) {
                    Navigator.of(context).pop();
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Respuesta de la API inválida')),
                    );
                  }
                }
              } else {
                // Cierra el cuadro de diálogo de carga
                if (mounted) {
                  Navigator.of(context).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al procesar la imagen')),
                  );
                }
              }
            } else {
              // Cierra el cuadro de diálogo de carga
              if (mounted) {
                Navigator.of(context).pop();
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario no autenticado')),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('No se detectó un círculo rojo en la imagen')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se detectaron grietas')),
            );
          }
        }
      } catch (e) {
        print("Error al enviar la imagen: $e");
        if (mounted) {
          Navigator.of(context).pop(); // Cierra el cuadro de diálogo de carga en caso de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al enviar la imagen')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una imagen')),
        );
      }
    }
  }

  Future<File> _convertBase64ToFile(String base64Image) async {
    final decodedBytes = base64Decode(base64Image);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${Uuid().v4()}.png';
    final file = File(filePath);
    await file.writeAsBytes(decodedBytes);
    return file;
  }

  Future<bool> _classifyImage(XFile image) async {
    try {
      // Crear una solicitud multipart para enviar la imagen a la API
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://r964z9v6-8000.brs.devtunnels.ms/classify/'));

      // Añadir la imagen a la solicitud
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      

      var response = await request.send();

      if (response.statusCode == 200) {
        // Leer la respuesta de la API
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        // Verifica si la respuesta contiene una predicción de grieta
        if (decodedData.containsKey('prediction') &&
            decodedData['prediction'] == 'Crack Detected') {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print("Error al clasificar la imagen: $e");
      return false;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Los servicios de ubicación están deshabilitados.");
      return Future.error('Los servicios de ubicación están deshabilitados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Los permisos de ubicación están denegados.");
        return Future.error('Los permisos de ubicación están denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Los permisos de ubicación están denegados permanentemente.");
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromPosition(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  Future<int?> _detectCircleDiameter(XFile image) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://r964z9v6-8000.brs.devtunnels.ms/detectar-circulos/'));

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      

      var response = await request.send();

      if (response.statusCode == 200) {
        // lee los datos de manera secuencial
        final responseData = await response.stream.bytesToString();
        // decodifica los datos JSON a un Map
        final decodedData = json.decode(responseData);

        // Verifica si la respuesta contiene un mensaje con un número
        if (decodedData.containsKey('message') &&
            decodedData['message'] != null) {
          final message = decodedData['message'];

          // Extrae el número del mensaje usando una expresión regular, r= string sin procesar
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

  Future<String> _uploadImageToFirebaseStorage(String userId, File image) async {
    try {
      // Generar un nombre único para la imagen usando un UUID
      const uuid = Uuid();
      final uniqueImageName = '${uuid.v4()}_${image.path.split('/').last}';

      final storageRef = FirebaseStorage.instance.ref().child('users/$userId/$uniqueImageName');
      final uploadTask = storageRef.putFile(image);
      //espera a que la subida se compete y devuelve un snapshot
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("Imagen subida a Firebase Storage: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error al subir la imagen a Firebase Storage: $e");
      throw Exception('Error al subir la imagen a Firebase Storage');
    }
  }

  Future<void> _sendResultsToFirestore(String userId, double maxCrackWidth,
      String imageUrl, String nivelDeRiesgo, String address, String convertedImageUrl) async {
    try {
      // Redondea el ancho de la grieta a dos decimales
      double maxCrackWidthRounded =
          double.parse(maxCrackWidth.toStringAsFixed(2));

      // Crea una nueva referencia de documento para almacenar los resultados
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('results')
          .add({
        'max_crack_width': maxCrackWidthRounded,
        'image_url': imageUrl,
        'nivel_de_riesgo': nivelDeRiesgo,
        'direccion': address, // Añadir la dirección
        'converted_image_url': convertedImageUrl, // Añadir la URL de la imagen convertida
        'timestamp': FieldValue.serverTimestamp(), // Añadir marca de tiempo
      });
    } catch (e) {
      print("Error al enviar los resultados a Firestore: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al guardar los resultados en Firestore')),
        );
      }
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
                        color: Colors.grey.withOpacity(0.1),
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
                  onClick: _sendImageToAPI,
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