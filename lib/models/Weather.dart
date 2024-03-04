import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Weather {
  final String condition;
  final double temperature;
  final double feelsLike;
  final double precipitation;
  final double windSpeed;
  final String windDirection;
  final int humidity;
  final int chanceOfRain;
  final int aqi;
  final int uvIndex;
  final int pressure;
  final double visibility;
  final String sunriseTime;
  final String sunsetTime;
  final String description;
  final String locationName;
  final Uint8List weatherIcon;
  final DateTime date;

  Weather({
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.chanceOfRain,
    required this.aqi,
    required this.uvIndex,
    required this.pressure,
    required this.visibility,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.description,
    required this.locationName,
    required this.weatherIcon,
    required this.date,
  });

  static Future<Weather?> fromJson(Map<String, dynamic> data) async {
    try {
      final main = data['main'];
      final wind = data['wind'];
      final sys = data['sys'];
      final weather = data['weather'][0];

      // Fetch weather icon
      final iconCode = weather['icon'];
      final iconUrl = 'https://api.openweathermap.org/img/w/$iconCode.png';
      final iconBytes = await _fetchWeatherIcon(iconUrl);

      return Weather(
        condition: weather['main'], // Example: 'Clear', 'Clouds', etc.
        temperature: main['temp'].toDouble() / 10,
        feelsLike: main['feels_like'].toDouble() / 10,
        precipitation: 0.0, // You need to parse precipitation data accordingly
        windSpeed: wind['speed'].toDouble(),
        windDirection: '', // You need to parse wind direction data accordingly
        humidity: main['humidity'],
        chanceOfRain: 0, // You need to parse chance of rain data accordingly
        aqi: 0, // You need to parse AQI data accordingly
        uvIndex: 0, // You need to parse UV index data accordingly
        pressure: main['pressure'],
        visibility:
            (data['visibility'] ?? 0) / 1000.0, // Convert meters to kilometers
        sunriseTime: DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000)
            .toString(),
        sunsetTime: DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000)
            .toString(),
        description: weather['description'],
        locationName: data['name'],
        weatherIcon: iconBytes,
        date: DateTime.now(),
      );
    } catch (e) {
      // Handle parsing errors
      print('Error parsing weather data: $e');
      return null;
    }
  }

  static Future<Uint8List> _fetchWeatherIcon(String iconUrl) async {
    try {
      final response = await http.get(Uri.parse(iconUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Error fetching weather icon: ${response.statusCode}');
        // Return default icon
        return await _getDefaultIcon();
      }
    } catch (e) {
      print('Error fetching weather icon: $e');
      // Return default icon
      return await _getDefaultIcon();
    }
  }

  static Future<Uint8List> _getDefaultIcon() async {
    // Placeholder icon
    return Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  }
}
