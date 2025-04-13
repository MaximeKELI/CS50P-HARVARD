import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AgriculturalUtils {
  static double calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].latitude * points[j].longitude;
      area -= points[i].longitude * points[j].latitude;
    }
    
    area = area.abs() * 0.5;
    // Conversion en hectares (approx.)
    return area * 11132 * 11132 * 0.0001; 
  }

  static String getCropIconPath(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'maïs': return 'assets/crops/maize.png';
      case 'blé': return 'assets/crops/wheat.png';
      case 'soja': return 'assets/crops/soybean.png';
      default: return 'assets/crops/generic.png';
    }
  }

  static Color getHealthColor(double ndviValue) {
    if (ndviValue > 0.6) return Colors.green;
    if (ndviValue > 0.3) return Colors.yellow;
    return Colors.red;
  }
}