import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/color.dart';

class ButtonWidget extends StatefulWidget {
  final String btnText;
  final VoidCallback? onClick;

  const ButtonWidget({super.key, required this.btnText, this.onClick});

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
              begin: Alignment.centerRight),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.btnText,
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}