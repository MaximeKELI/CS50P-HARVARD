import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AgriculturalPlot {
  final String id;
  final String name;
  final String cropType;
  final List<LatLng> boundary;
  final double? estimatedArea; // en hectares
  final DateTime creationDate;
  final Map<String, dynamic>? droneMetadata;
  final Map<String, dynamic>? soilData;

  AgriculturalPlot({
    required this.id,
    required this.name,
    required this.cropType,
    required this.boundary,
    this.estimatedArea,
    this.droneMetadata,
    this.soilData,
    DateTime? creationDate,
  }) : creationDate = creationDate ?? DateTime.now();

  /// Factory method pour créer une parcelle depuis Firestore
  factory AgriculturalPlot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AgriculturalPlot(
      id: doc.id,
      name: data['name'] ?? 'Parcelle sans nom',
      cropType: data['cropType'] ?? 'Non spécifié',
      boundary: _parseBoundary(data['boundary']),
      estimatedArea: (data['estimatedArea'] as num?)?.toDouble(),
      droneMetadata: data['droneMetadata'],
      soilData: data['soilData'],
      creationDate: (data['creationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertit la liste des points en LatLng
  static List<LatLng> _parseBoundary(dynamic boundaryData) {
    if (boundaryData == null) return [];
    return (boundaryData as List).map((point) => 
      LatLng(point['latitude'], point['longitude'])
    ).toList();
  }

  /// Convertit une instance en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'cropType': cropType,
      'boundary': boundary.map((point) => 
        {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      'estimatedArea': estimatedArea,
      'droneMetadata': droneMetadata,
      'soilData': soilData,
      'creationDate': Timestamp.fromDate(creationDate),
    };
  }

  /// Permet de créer une copie modifiée de l'objet
  AgriculturalPlot copyWith({
    String? id,
    String? name,
    String? cropType,
    List<LatLng>? boundary,
    double? estimatedArea,
    Map<String, dynamic>? droneMetadata,
    Map<String, dynamic>? soilData,
    DateTime? creationDate,
  }) {
    return AgriculturalPlot(
      id: id ?? this.id,
      name: name ?? this.name,
      cropType: cropType ?? this.cropType,
      boundary: boundary ?? this.boundary,
      estimatedArea: estimatedArea ?? this.estimatedArea,
      droneMetadata: droneMetadata ?? this.droneMetadata,
      soilData: soilData ?? this.soilData,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}
