import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "TA_CLEF_API"; // Remplace avec ta clé OpenWeatherMap
  static const String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  static Future<double> getSoilMoisture(double lat, double lon) async {
    final url = Uri.parse("$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['main']['humidity'].toDouble(); // Simule l'humidité du sol
    } else {
      throw Exception("Échec de récupération des données météo");
    }
  }
}
