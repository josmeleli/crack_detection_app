import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class ButtonWidget extends StatefulWidget {
  final String btnText;
  final VoidCallback? onClick;
  final IconData? icon; // Icono opcional
  final TextStyle? textStyle; // Estilo de texto opcional

  const ButtonWidget({
    super.key,
    required this.btnText,
    this.onClick,
    this.icon, // Inicializar el icono opcional
    this.textStyle, // Inicializar el estilo de texto opcional
  });

  @override
  ButtonWidgetState createState() => ButtonWidgetState();
}

class ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onClick,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            end: Alignment.centerLeft,
            begin: Alignment.centerRight,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8), // Espacio entre el icono y el texto
            ],
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              child: Text(
                widget.btnText,
                style: widget.textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}