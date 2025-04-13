import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getWeatherData();
  }

  Future<void> _getWeatherData() async {
    try {
      // 1. Vérification des permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Veuillez activer la localisation';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          setState(() {
            _errorMessage = 'Permission de localisation refusée';
            _isLoading = false;
          });
          return;
        }
      }

      // 2. Récupération position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // 3. Appel API météo (OpenWeatherMap)
      final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=VOTRE_CLE_API&units=metric&lang=fr',
      ));

      if (response.statusCode == 200) {
        setState(() {
          _currentPosition = position;
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur API météo');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les données météo';
        _isLoading = false;
      });
    }
  }

  Widget _buildWeatherAnimation(String? mainCondition) {
    String animationUrl;
    
    switch (mainCondition?.toLowerCase()) {
      case 'clear':
        animationUrl = 'https://assets5.lottiefiles.com/packages/lf20_tn1fe3we.json';
        break;
      case 'rain':
        animationUrl = 'https://assets1.lottiefiles.com/packages/lf20_2wCMYz.json';
        break;
      case 'clouds':
        animationUrl = 'https://assets1.lottiefiles.com/packages/lf20_okvhqjnr.json';
        break;
      default:
        animationUrl = 'https://assets5.lottiefiles.com/packages/lf20_tn1fe3we.json';
    }

    return SizedBox(
      height: 250,
      child: Lottie.network(
        animationUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.wb_sunny, size: 100, color: Colors.amber);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Météo en temps réel"),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getWeatherData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildWeatherAnimation(_weatherData?['weather'][0]['main']),
                      
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildWeatherInfo('Localisation', 
                              '${_weatherData?['name']}', Icons.location_on),
                            _buildWeatherInfo('Température', 
                              '${_weatherData?['main']['temp']?.round()}°C', Icons.thermostat),
                            _buildWeatherInfo('Ressenti', 
                              '${_weatherData?['main']['feels_like']?.round()}°C', Icons.device_thermostat),
                            _buildWeatherInfo('Humidité', 
                              '${_weatherData?['main']['humidity']}%', Icons.water_drop),
                            _buildWeatherInfo('Vent', 
                              '${(_weatherData?['wind']['speed'] * 3.6).toStringAsFixed(1)} km/h', Icons.air),
                          ],
                        ),
                      ),

                      if (_weatherData?['weather'][0]['description'] != null)
                        _buildWeatherAlert(
                          '${_weatherData?['weather'][0]['description']}'.capitalize(),
                          _weatherData?['weather'][0]['main'] == 'Rain' 
                              ? Colors.blue[100]! 
                              : Colors.orange[100]!,
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWeatherAlert(String message, Color bgColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[800]),
              SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}