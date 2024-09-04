import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Instrucciones',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepCard(
                  context,
                  '1. Primero, ve a tu perfil y asegúrate de configurar el diámetro del círculo rojo en milímetros (mm).',
                  'assets/images/paso-1-bg.png',
                ),
                _buildStepCard(
                  context,
                  '2. Luego, accede a la sección "Detectar", acepta los permisos necesarios y captura o sube una imagen de la grieta.',
                  'assets/images/paso-2-bg.png',
                ),
                _buildStepCard(
                  context,
                  '3. Una vez que la imagen se haya cargado (asegúrate de que sea nítida), podrás presionar el botón "Detectar".',
                  'assets/images/paso-3-bg.png',
                ),
                _buildStepCard(
                  context,
                  '4. Finalmente, los detalles del riesgo de la grieta se guardarán en la sección de resultados.',
                  'assets/images/paso-4-bg.png',
                ),
                const SizedBox(height: 20),
                Text(
                  'Importante: La detección se clasifica en niveles de riesgo, de alto a bajo, según el ancho de la grieta en milímetros (mm).',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: riskHighColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, String text, String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
