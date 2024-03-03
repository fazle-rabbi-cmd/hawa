import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/Weather.dart';

class WeatherService {
  static const String _iconBaseUrl = 'https://openweathermap.org/img/wn';
  static const String _apiKey =
      'c0d1009550c934bb96a545c2d2f38878'; // Replace with your weather API key
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather'; // Example base URL

  static Future<Weather> fetchWeatherData(
      double latitude, double longitude) async {
    try {
      if (kDebugMode) {
        print('Fetching weather data for coordinates: $latitude, $longitude');
      }
      final response = await http.get(
          Uri.parse('$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey'));
      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
      }
      final Map<String, dynamic> data = json.decode(response.body);
      if (kDebugMode) {
        print('Response data: $data');
      }
      if (response.statusCode == 200) {
        final weatherDescription = data['weather'][0]['description'];
        final locationName = data['name'];
        final weatherIconCode = data['weather'][0]['icon'];
        final weatherIconUrl =
            'http://openweathermap.org/img/wn/$weatherIconCode.png';
        final weatherIconResponse = await http.get(Uri.parse(weatherIconUrl));
        if (weatherIconResponse.statusCode == 200) {
          final weatherIcon = weatherIconResponse.bodyBytes;
          return Weather(
            temperature: data['main']['temp'] / 10,
            feelsLike: data['main']['feels_like'] / 10,
            precipitation: data['rain'] != null ? data['rain']['1h'] : 0.0,
            windSpeed: data['wind']['speed'],
            windDirection: data['wind']['deg'].toString(),
            humidity: data['main']['humidity'],
            chanceOfRain: 0,
            aqi: 0,
            uvIndex: 0,
            pressure: data['main']['pressure'],
            visibility: data['visibility'] / 1000,
            sunriseTime: DateTime.fromMillisecondsSinceEpoch(
                    data['sys']['sunrise'] * 1000)
                .toString(),
            sunsetTime: DateTime.fromMillisecondsSinceEpoch(
                    data['sys']['sunset'] * 1000)
                .toString(),
            description: weatherDescription,
            locationName: locationName,
            weatherIcon: weatherIcon,
          );
        } else {
          throw Exception('Failed to fetch weather icon');
        }
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      throw Exception('Failed to fetch weather data');
    }
  }

  static Future<Weather?> fetchWeatherDataForLocation(
      String locationName) async {
    try {
      if (kDebugMode) {
        print('Fetching weather data for location: $locationName');
      }
      final response =
          await http.get(Uri.parse('$_baseUrl?q=$locationName&appid=$_apiKey'));
      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
      }

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        throw Exception('Invalid response');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather data for location: $e');
      }
      return null; // Return null in case of error
    }
  }
}
