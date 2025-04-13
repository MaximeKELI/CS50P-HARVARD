import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class NdviService {
  static Future<Uint8List> generateNdviMap(List<LatLng> boundary) async {
    // Simulation - En production, utiliser une vraie API NDVI
    final mockNdviUrl = _generateMockNdviUrl(boundary);
    
    try {
      final response = await http.get(Uri.parse(mockNdviUrl));
      if (response.statusCode == 200) {
        return _applyNdviColormap(response.bodyBytes);
      }
      throw Exception('Erreur HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Échec génération NDVI: $e');
    }
  }

  static String _generateMockNdviUrl(List<LatLng> boundary) {
    final center = _calculateCenter(boundary);
    return 'https://mock-ndvi-service.com/?lat=${center.latitude}&lng=${center.longitude}';
  }

  static LatLng _calculateCenter(List<LatLng> points) {
    double lat = 0, lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  static Uint8List _applyNdviColormap(Uint8List imageData) {
    // Simulation de traitement NDVI
    final image = img.decodeImage(imageData);
    final ndviImage = img.Image(width: image!.width, height: image.height);
    
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // Fausse transformation NDVI (rouge = végétation saine)
        final ndviValue = (pixel.r - pixel.b) / (pixel.r + pixel.b + 0.001);
        final color = ndviValue > 0.3 
            ? img.ColorRgb8(0, (ndviValue * 200).toInt(), 0)
            : img.ColorRgb8((ndviValue * 255).abs().toInt(), 0, 0);
        ndviImage.setPixel(x, y, color);
      }
    }
    
    return Uint8List.fromList(img.encodePng(ndviImage));
  }
}