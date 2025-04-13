import 'package:app_agrigeo/screens/agricultural_plot.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:app_agrigeo/lib/screens/agricultural_plot.dart';
import 'package:app_agrigeo/screens/parcel_form.dart';
import 'package:app_agrigeo/services/ndvi_service.dart';
import 'package:app_agrigeo/utils/agricultural_utils.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Polygon> _parcels = {};
  final Set<Marker> _agriculturalMarkers = {};
  final Map<String, AgriculturalPlot> _plotData = {};
  LatLng _currentLocation = LatLng(5.3489, -4.0036);
  bool _isLoading = true;
  String? _selectedParcelId;
  BitmapDescriptor? _cropIcon;

  // Services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _initializeLocation();
    _loadAgriculturalData();
  }

  Future<void> _loadCustomMarker() async {
    final icon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/crop_marker.png',
    );
    setState(() => _cropIcon = icon);
  }

  Future<void> _initializeLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Erreur localisation: $e');
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Localisation requise pour la cartographie agricole')),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _loadAgriculturalData() async {
    try {
      // Chargement des parcelles existantes
      final plotsSnapshot = await _firestore.collection('agricultural_plots').get();
      
      for (var doc in plotsSnapshot.docs) {
        final plot = AgriculturalPlot.fromFirestore(doc);
        _addPlotToMap(plot, doc.id);
      }

      // Chargement des marqueurs agricoles
      final markersSnapshot = await _firestore.collection('field_markers').get();
      for (var doc in markersSnapshot.docs) {
        _addAgriculturalMarker(doc);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

  void _addPlotToMap(AgriculturalPlot plot, String id) {
    final polygon = Polygon(
      polygonId: PolygonId(id),
      points: plot.boundary,
      strokeWidth: 3,
      strokeColor: _getPlotColor(plot.cropType),
      fillColor: _getPlotColor(plot.cropType).withOpacity(0.2),
      onTap: () => _onParcelTapped(id, plot),
    );

    setState(() {
      _parcels.add(polygon);
      _plotData[id] = plot;
    });
  }

  Color _getPlotColor(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'maïs': return Colors.green;
      case 'blé': return Colors.amber;
      case 'soja': return Colors.lightGreen;
      case 'riz': return Colors.teal;
      default: return Colors.blue;
    }
  }

  void _addAgriculturalMarker(QueryDocumentSnapshot doc) {
    final marker = Marker(
      markerId: MarkerId(doc.id),
      position: LatLng(doc['latitude'], doc['longitude']),
      infoWindow: InfoWindow(
        title: doc['title'],
        snippet: doc['description'],
      ),
      icon: _cropIcon ?? BitmapDescriptor.defaultMarker,
      onTap: () => _showMarkerDetails(doc),
    );

    setState(() => _agriculturalMarkers.add(marker));
  }

  Future<void> _addFieldObservation() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      // Upload vers Firebase Storage
      final file = File(image.path);
      final fileName = 'field_observations/${DateTime.now().toIso8601String()}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      final imageUrl = await ref.getDownloadURL();

      // Enregistrement dans Firestore
      await _firestore.collection('field_markers').add({
        'latitude': _currentLocation.latitude,
        'longitude': _currentLocation.longitude,
        'imageUrl': imageUrl,
        'title': 'Observation terrain',
        'description': 'Ajoutée ${DateTime.now().toString()}',
        'type': 'observation',
        'cropType': _selectedParcelId != null 
            ? _plotData[_selectedParcelId]?.cropType 
            : null,
      });

      _loadAgriculturalData(); // Rafraîchir les données
    } catch (e) {
      debugPrint('Erreur ajout observation: $e');
    }
  }

  void _onParcelTapped(String id, AgriculturalPlot plot) {
    setState(() => _selectedParcelId = id);
    _showParcelInfo(plot);
  }

  void _showParcelInfo(AgriculturalPlot plot) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plot.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Culture: ${plot.cropType}'),
            Text('Surface: ${plot.estimatedArea?.toStringAsFixed(2) ?? 'N/A'} ha'),
            if (plot.droneMetadata != null) ...[
              SizedBox(height: 8),
              Text('Données drone:',
                style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Résolution: ${plot.droneMetadata!['resolution']}'),
              if (plot.droneMetadata!['ndvi_available'] == true)
                ElevatedButton(
                  onPressed: () => _showNdviAnalysis(plot),
                  child: Text('Voir analyse NDVI'),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMarkerDetails(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (doc['imageUrl'] != null)
              Image.network(doc['imageUrl']),
            SizedBox(height: 10),
            Text(doc['description']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNdviAnalysis(AgriculturalPlot plot) async {
    try {
      final ndviImage = await NdviService.generateNdviMap(plot.boundary);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Analyse NDVI - ${plot.name}'),
          content: Image.memory(ndviImage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur génération NDVI: $e')),
      );
    }
  }

  Future<void> _createNewParcel() async {
    final plot = await showDialog<AgriculturalPlot>(
      context: context,
      builder: (context) => PrecisionAgricultureParcelForm(onSave: (AgriculturalPlot ) {  },),
    );

    if (plot != null) {
      final docRef = await _firestore.collection('agricultural_plots').add(plot.toFirestore());
      _addPlotToMap(plot, docRef.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartographie Agricole'),
        actions: [
          IconButton(
            icon: Icon(Icons.legend_toggle),
            onPressed: _showLegend,
            tooltip: 'Légende des cultures',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            polygons: _parcels,
            markers: _agriculturalMarkers,
            myLocationEnabled: true,
            onCameraMove: (position) => _currentLocation = position.target,
            mapType: MapType.hybrid,
          ),

          if (_isLoading)
            Center(child: CircularProgressIndicator()),

          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'gps',
              mini: true,
              onPressed: _centerToLocation,
              child: Icon(Icons.gps_fixed),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_parcel',
            onPressed: _createNewParcel,
            child: Icon(Icons.add),
            tooltip: 'Ajouter une parcelle',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add_observation',
            onPressed: _addFieldObservation,
            child: Icon(Icons.camera_alt),
            tooltip: 'Ajouter une observation',
          ),
        ],
      ),
    );
  }

  Future<void> _centerToLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16,
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Légende des Cultures'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem('Maïs', Colors.green),
            _buildLegendItem('Blé', Colors.amber),
            _buildLegendItem('Soja', Colors.lightGreen),
            _buildLegendItem('Riz', Colors.teal),
            _buildLegendItem('Autres', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}