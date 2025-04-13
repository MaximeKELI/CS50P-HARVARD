import 'package:flutter/material.dart';
import 'package:app_agrigeo/widgets/irrigation_slider.dart';

class IrrigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion de l'Irrigation")),
      body: Center(child: IrrigationSlider()),
    );
  }
}
