import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/detection_page.dart';
import 'package:flutter_application_1/pages/info_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/results_page.dart';
import 'package:flutter_application_1/utils/color.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa el controlador una sola vez
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) {
            controller.selectedIndex.value = index;
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.info), label: 'Instrucciones'),
            NavigationDestination(icon: Icon(Icons.add), label: 'Detectar'),
            NavigationDestination(icon: Icon(Icons.assessment), label: 'Resultados'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
          indicatorColor: secondaryColor,
          
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const InfoPage(),
    const DetectionPage(),
    const ResultsPage(),
    const ProfilePage(),
  ];
}