import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:flutter_application_1/widgets/appbar_widget.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Instructions',
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
                  "1. First, go to your profile and make sure to set the red circle's diameter in millimeters (mm).",
                  'assets/images/paso-1-bg.png',
                ),
                _buildStepCard(
                  context,
                  '2. Then, go to the "Detect" section, accept the necessary permissions, and capture or upload an image of the crack.',
                  'assets/images/paso-2-bg.png',
                ),
                _buildStepCard(
                  context,
                  '3. Once the image has been uploaded (make sure it is clear), you can press the "Detect" button.',
                  'assets/images/paso-3-bg.png',
                ),
                _buildStepCard(
                  context,
                  '4. Finally, the crack risk details will be saved in the results section.',
                  'assets/images/paso-4-bg.png',
                ),
                const SizedBox(height: 20),
                Text(
                  'Important: The detection is classified into risk levels, from high to low, based on the crack width in millimeters (mm).',
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
