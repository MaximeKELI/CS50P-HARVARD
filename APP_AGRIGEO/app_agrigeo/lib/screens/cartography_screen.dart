import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_agrigeo/screens/agricultural_plot.dart';
import 'package:app_agrigeo/screens/parcel_form.dart';
import 'dart:math' as math;

class CartographyScreen extends StatefulWidget {
  const CartographyScreen({Key? key}) : super(key: key);

  @override
  CartographyScreenState createState() => CartographyScreenState();
}

class CartographyScreenState extends State<CartographyScreen> {
  GoogleMapController? _mapController;
  final Set<Polygon> _parcels = {};
  final Set<Marker> _markers = {};
  LatLng _currentLocation = const LatLng(5.3489, -4.0036);
  AgriculturalPlot? _selectedPlot;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activez le GPS pour utiliser cette fonction'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions requises pour la localisation'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Permissions'),
              content: const Text(
                'Autorisez l\'accès à la localisation dans les paramètres',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text('Paramètres'),
                ),
              ],
            ),
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de localisation: ${e.toString()}')),
      );
    }
  }

  Future<void> centerToLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de centrage: ${e.toString()}')),
      );
    }
  }

  void _showParcelForm() {
    showDialog(
      context: context,
      builder:
          (context) => PrecisionAgricultureParcelForm(
            onSave: (AgriculturalPlot plot) {
              _addPlotToMap(plot);
              Navigator.pop(context);
            },
          ),
    );
  }

  void _addPlotToMap(AgriculturalPlot plot) {
    final polygonId = PolygonId(
      'parcel_${DateTime.now().millisecondsSinceEpoch}',
    );
    final area = _calculatePolygonArea(plot.boundary);

    setState(() {
      _parcels.add(
        Polygon(
          polygonId: polygonId,
          points: plot.boundary,
          strokeWidth: 3,
          strokeColor: _getPlotColor(plot.cropType),
          fillColor: _getPlotColor(plot.cropType).withOpacity(0.2),
          onTap: () => _showPlotDetails(plot, area),
        ),
      );
    });
  }

  Color _getPlotColor(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'maïs':
        return Colors.green;
      case 'blé':
        return Colors.amber;
      case 'soja':
        return Colors.lightGreen;
      case 'riz':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;

    double area = 0.0;
    final p1 = points[0];
    LatLng p2, p3;

    for (int i = 1; i < points.length - 1; i++) {
      p2 = points[i];
      p3 = points[i + 1];

      area += _calculateTriangleArea(p1, p2, p3);
    }

    // Conversion en hectares (1 degré ≈ 111 km)
    return (area.abs() * 111 * 111) / 10000;
  }

  double _calculateTriangleArea(LatLng a, LatLng b, LatLng c) {
    return ((b.latitude - a.latitude) * (c.longitude - a.longitude) -
            (b.longitude - a.longitude) * (c.latitude - a.latitude)) /
        2;
  }

  void _showPlotDetails(AgriculturalPlot plot, double area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.4,
            maxChildSize: 0.8,
            builder:
                (_, controller) => SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plot.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: _getPlotColor(plot.cropType)),
                        ),
                        const Divider(),
                        _buildDetailTile(
                          Icons.agriculture,
                          'Culture',
                          plot.cropType,
                        ),
                        _buildDetailTile(
                          Icons.square_foot,
                          'Surface',
                          '${area.toStringAsFixed(2)} ha',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _zoomToPlot(plot),
                          child: const Text('Zoomer sur la parcelle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _zoomToPlot(AgriculturalPlot plot) {
    final bounds = _calculateBounds(plot.boundary);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (final point in points) {
      minLat =
          minLat == null ? point.latitude : math.min(minLat, point.latitude);
      maxLat =
          maxLat == null ? point.latitude : math.max(maxLat, point.latitude);
      minLng =
          minLng == null ? point.longitude : math.min(minLng, point.longitude);
      maxLng =
          maxLng == null ? point.longitude : math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      northeast: LatLng(maxLat!, maxLng!),
      southwest: LatLng(minLat!, minLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            polygons: _parcels,
            markers: _markers,
            myLocationEnabled: true,
            mapType: MapType.hybrid,
          ),

          // Boutons en haut à droite
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'add_parcel',
                      onPressed: _showParcelForm,
                      child: const Icon(Icons.add),
                      tooltip: 'Ajouter une parcelle',
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton(
                      heroTag: 'center_location',
                      onPressed: centerToLocation,
                      child: const Icon(Icons.gps_fixed),
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Légende en bas à gauche
          Positioned(
            bottom: 20,
            left: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(Colors.green, 'Maïs'),
                    _buildLegendItem(Colors.amber, 'Blé'),
                    _buildLegendItem(Colors.lightGreen, 'Soja'),
                    _buildLegendItem(Colors.teal, 'Riz'),
                    _buildLegendItem(Colors.blue, 'Autre'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
