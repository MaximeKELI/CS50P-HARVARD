import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel extends ChangeNotifier {
  String? _name;
  String? _role;
  String? _email;
  String? _phone;
  String? _farmName;
  String? _location;

  // Getters
  String? get name => _name;
  String? get role => _role;
  String? get email => _email;
  String? get phone => _phone;
  String? get farmName => _farmName;
  String? get location => _location;
  bool get isFarmer => _role == 'farmer';
  bool get isVisitor => _role == 'visitor';

  // Charger les données utilisateur
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('userName');
    _role = prefs.getString('userRole');
    _email = prefs.getString('userEmail');
    _phone = prefs.getString('userPhone');
    _farmName = prefs.getString('userFarmName');
    _location = prefs.getString('userLocation');
    notifyListeners();
  }

  // Enregistrer les données utilisateur
  Future<void> setUser(
    String name, {
    required String role,
    String? email,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString('userName', name),
      prefs.setString('userRole', role),
      if (email != null) prefs.setString('userEmail', email),
      if (phone != null) prefs.setString('userPhone', phone),
      if (farmName != null) prefs.setString('userFarmName', farmName),
      if (location != null) prefs.setString('userLocation', location),
    ]);

    _name = name;
    _role = role;
    _email = email;
    _phone = phone;
    _farmName = farmName;
    _location = location;
    notifyListeners();
  }

  // Mettre à jour le profil
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString('userName', name);
      _name = name;
    }
    if (email != null) {
      await prefs.setString('userEmail', email);
      _email = email;
    }
    if (phone != null) {
      await prefs.setString('userPhone', phone);
      _phone = phone;
    }
    if (farmName != null && isFarmer) {
      await prefs.setString('userFarmName', farmName);
      _farmName = farmName;
    }
    if (location != null && isFarmer) {
      await prefs.setString('userLocation', location);
      _location = location;
    }

    notifyListeners();
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _name = null;
    _role = null;
    _email = null;
    _phone = null;
    _farmName = null;
    _location = null;
    notifyListeners();
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userName');
  }

  // Obtenir les données utilisateur sous forme de Map
  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'role': _role,
      'email': _email,
      'phone': _phone,
      'farmName': _farmName,
      'location': _location,
    };
  }
}
