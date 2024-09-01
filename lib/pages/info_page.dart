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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('1. Primero, ve a la interfaz Detectar.'),
                Image(image: AssetImage('assets/images/info2.png'), width: 250,), 
                SizedBox(height: 20),

                Text('2. Luego abre la cámara o sube una imagen (asegúrate de capturar una imagen nítida); si te equivocaste, simplemente vuelve a capturarla.'),
                Image(image: AssetImage('assets/images/info2.png'), width: 250,), 
                SizedBox(height: 20),

                Text('3. Después, la imagen se cargará y podrás presionar el botón "Detectar".'),
                Image(image: AssetImage('assets/images/info2.png'), width: 250,), 
                SizedBox(height: 20),
                Text('4. Finalmente, al presionar "Detectar", la imagen se almacenará en la interfaz resultados, donde podrás hacer clic para verla en detalle.'),
                Image(image: AssetImage('assets/images/info2.png'), width: 250,), 
                SizedBox(height: 20),
                Text('Importante: La detección se divide en niveles de riesgo de alto a bajo dependiendo el ancho de la grieta.'),
              

              ],
            ),
          ),
        ),
      ),
    );
  }
}