// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http/http.dart' as http;
// import 'package:hawa/services/WeatherService.dart';
//
// class Weather {
//   final double temperature;
//   final double feelsLike;
//   final double precipitation;
//   final double windSpeed;
//   final String windDirection;
//   final int humidity;
//   final int chanceOfRain;
//   final int aqi;
//   final int uvIndex;
//   final int pressure;
//   final double visibility;
//   final String sunriseTime;
//   final String sunsetTime;
//   final String description;
//   final String locationName;
//   final Uint8List weatherIcon;
//
//   Weather({
//     required this.temperature,
//     required this.feelsLike,
//     required this.precipitation,
//     required this.windSpeed,
//     required this.windDirection,
//     required this.humidity,
//     required this.chanceOfRain,
//     required this.aqi,
//     required this.uvIndex,
//     required this.pressure,
//     required this.visibility,
//     required this.sunriseTime,
//     required this.sunsetTime,
//     required this.description,
//     required this.locationName,
//     required this.weatherIcon,
//   });
//
//   static Future<Weather?> fromJson(Map<String, dynamic> data) async {
//     try {
//       final main = data['main'];
//       final wind = data['wind'];
//       final sys = data['sys'];
//       final weather = data['weather'][0];
//
//       // Fetch weather icon data asynchronously
//       final _weatherIcon = await _fetchWeatherIcon(weather['icon']);
//
//       return Weather(
//         temperature: main['temp'].toDouble(),
//         feelsLike: main['feels_like'].toDouble(),
//         precipitation: 0.0, // You need to parse precipitation data accordingly
//         windSpeed: wind['speed'].toDouble(),
//         windDirection: '', // You need to parse wind direction data accordingly
//         humidity: main['humidity'],
//         chanceOfRain: 0, // You need to parse chance of rain data accordingly
//         aqi: 0, // You need to parse AQI data accordingly
//         uvIndex: 0, // You need to parse UV index data accordingly
//         pressure: main['pressure'],
//         visibility: data['visibility'] / 1000.0, // Convert meters to kilometers
//         sunriseTime: DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000)
//             .toString(),
//         sunsetTime: DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000)
//             .toString(),
//         description: weather['description'],
//         locationName: data['name'],
//         weatherIcon: _weatherIcon,
//       );
//     } catch (e) {
//       // Handle parsing errors
//       print('Error parsing weather data: $e');
//       return null;
//     }
//   }
// }
//
// Future<Uint8List> _fetchWeatherIcon(String iconCode) async {
//   const int maxAttempts = 3;
//   for (int attempt = 1; attempt <= maxAttempts; attempt++) {
//     try {
//       final response = await http
//           .get(Uri.parse('https://api.openweathermap.org/img/w/$iconCode.png'));
//       if (response.statusCode == 200) {
//         return response.bodyBytes;
//       } else {
//         print('Failed to fetch weather icon: ${response.statusCode}');
//         return _getDefaultIcon(); // Return default icon if fetching fails
//       }
//     } catch (e) {
//       print('Error fetching weather icon (attempt $attempt/$maxAttempts): $e');
//       if (attempt == maxAttempts) {
//         return _getDefaultIcon(); // Return default icon after max attempts
//       }
// // Wait for a short duration before retrying
//       await Future.delayed(Duration(seconds: 2));
//     }
//   }
//   return _getDefaultIcon(); // Fallback to default icon if all attempts fail
// }
//
// Uint8List _getDefaultIcon() {
// // Return default icon data (e.g., placeholder image)
//   return Uint8List.fromList([/* Add default icon bytes here */]);
// }
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Weather {
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

  Weather({
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
        visibility: data['visibility'] / 1000.0, // Convert meters to kilometers
        sunriseTime: DateTime.fromMillisecondsSinceEpoch(sys['sunrise'] * 1000)
            .toString(),
        sunsetTime: DateTime.fromMillisecondsSinceEpoch(sys['sunset'] * 1000)
            .toString(),
        description: weather['description'],
        locationName: data['name'],
        weatherIcon: iconBytes,
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
