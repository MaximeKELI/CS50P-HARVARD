import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_agrigeo/screens/agricultural_plot.dart'; // Import ajouté

class PrecisionAgricultureParcelForm extends StatefulWidget {
  final Function(AgriculturalPlot) onSave;
  
  const PrecisionAgricultureParcelForm({Key? key, required this.onSave}) : super(key: key);

  @override
  _PrecisionAgricultureParcelFormState createState() => _PrecisionAgricultureParcelFormState();
}

class _PrecisionAgricultureParcelFormState extends State<PrecisionAgricultureParcelForm> {
  final List<LatLng> _boundaryPoints = [];
  final TextEditingController _nameController = TextEditingController();
  String _selectedCrop = "Maïs";
  bool _isDroneConnected = false;
  bool _isTracking = false;
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  double? _calculatedArea;

  final List<String> _cropTypes = [
    "Maïs", "Blé", "Soja", "Riz", "Coton",
    "Canne à sucre", "Vigne", "Olivier", "Pomme de terre"
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = "Parcelle ${DateTime.now().day}/${DateTime.now().month}";
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _calculateArea() {
    if (_boundaryPoints.length < 3) {
      setState(() => _calculatedArea = null);
      return;
    }

    double area = 0;
    for (int i = 0; i < _boundaryPoints.length; i++) {
      final j = (i + 1) % _boundaryPoints.length;
      area += _boundaryPoints[i].latitude * _boundaryPoints[j].longitude;
      area -= _boundaryPoints[i].longitude * _boundaryPoints[j].latitude;
    }

    setState(() {
      _calculatedArea = (area.abs() * 0.5 * 11132 * 11132 * cos(_boundaryPoints[0].latitude * pi / 180)) / 10000;
    });
  }

  Future<void> _toggleDroneConnection() async {
    if (_isDroneConnected) {
      _disconnectDrone();
    } else {
      await _connectToDrone();
    }
  }

  Future<void> _connectToDrone() async {
    setState(() => _isDroneConnected = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Drone connecté - Mode agriculture de précision activé')),
    );
  }

  void _disconnectDrone() {
    setState(() => _isDroneConnected = false);
  }

  Future<void> _togglePositionTracking() async {
    if (_isTracking) {
      _stopTracking();
    } else {
      await _startTracking();
    }
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activez le service de localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        return;
      }
    }

    setState(() => _isTracking = true);

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      if (!_isTracking || !mounted) return;
      
      setState(() {
        _lastPosition = position;
        _boundaryPoints.add(LatLng(position.latitude, position.longitude));
        _calculateArea();
      });
    });
  }

  void _stopTracking() {
    _positionStream?.cancel();
    setState(() => _isTracking = false);
  }

  void _addManualPoint(double lat, double lng) {
    setState(() {
      _boundaryPoints.add(LatLng(lat, lng));
      _calculateArea();
    });
  }

  void _clearBoundary() {
    setState(() {
      _boundaryPoints.clear();
      _calculatedArea = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.agriculture, color: Colors.green),
          SizedBox(width: 10),
          Text("Gestion Parcellaire Agricole"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nom de la parcelle",
                        icon: Icon(Icons.text_fields),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      items: _cropTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _selectedCrop = newValue!);
                      },
                      decoration: const InputDecoration(
                        labelText: "Type de culture",
                        icon: Icon(Icons.spa),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text("Acquisition des limites", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: Icon(_isDroneConnected ? Icons.check : Icons.airplanemode_active),
                      label: Text(_isDroneConnected ? "Drone Connecté" : "Connecter Drone"),
                      onPressed: _toggleDroneConnection,
                      backgroundColor: _isDroneConnected ? Colors.green[100] : null,
                    ),
                    ActionChip(
                      avatar: Icon(_isTracking ? Icons.gps_fixed : Icons.gps_not_fixed),
                      label: Text(_isTracking ? "Suivi Actif" : "Suivi GPS"),
                      onPressed: _togglePositionTracking,
                      backgroundColor: _isTracking ? Colors.blue[100] : null,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.pin_drop),
                      label: const Text("Point Manuel"),
                      onPressed: _showManualPointDialog,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.import_export),
                      label: const Text("Importer"),
                      onPressed: _showImportDialog,
                    ),
                  ],
                ),
                if (_isDroneConnected) ...[
                  const SizedBox(height: 10),
                  Text("Mode Drone: Cartographie NDVI disponible", 
                      style: TextStyle(color: Colors.green)),
                ],
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Points de délimitation", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: _boundaryPoints.isNotEmpty ? _clearBoundary : null,
                          child: const Text("Effacer", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                    if (_calculatedArea != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Surface estimée: ${_calculatedArea!.toStringAsFixed(2)} hectares",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _boundaryPoints.isEmpty
                          ? const Center(child: Text("Aucun point enregistré", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _boundaryPoints.length,
                              itemBuilder: (context, index) {
                                final point = _boundaryPoints[index];
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    child: Text((index + 1).toString()),
                                    radius: 12,
                                  ),
                                  title: Text("${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _boundaryPoints.removeAt(index);
                                        _calculateArea();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Enregistrer Parcelle"),
          onPressed: _boundaryPoints.length >= 3
              ? () {
                  final plot = AgriculturalPlot(
                    id: '', // Ajout d'un id vide (sera généré par Firestore)
                    boundary: _boundaryPoints,
                    name: _nameController.text,
                    cropType: _selectedCrop,
                    estimatedArea: _calculatedArea,
                    droneMetadata: _isDroneConnected 
                        ? {"ndvi_available": true, "resolution": "10cm"} 
                        : null,
                  );
                  widget.onSave(plot);
                  Navigator.pop(context);
                }
              : null,
        ),
      ],
    );
  }

  void _showManualPointDialog() {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajout manuel"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
            ),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (latController.text.isNotEmpty && lngController.text.isNotEmpty) {
                _addManualPoint(
                  double.parse(latController.text),
                  double.parse(lngController.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Importer des données"),
        content: const Text("Fonctionnalité d'import à implémenter"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}