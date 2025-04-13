import 'package:flutter/material.dart';

class IrrigationSlider extends StatefulWidget {
  @override
  _IrrigationSliderState createState() => _IrrigationSliderState();
}

class _IrrigationSliderState extends State<IrrigationSlider> {
  double _waterLevel = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Niveau d'irrigation: ${_waterLevel.toInt()}%"),
        Slider(
          value: _waterLevel,
          min: 0,
          max: 100,
          divisions: 10,
          label: "${_waterLevel.toInt()}%",
          onChanged: (value) {
            setState(() {
              _waterLevel = value;
            });
          },
        ),
      ],
    );
  }
}
