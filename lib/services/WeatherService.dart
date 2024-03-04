import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/Weather.dart';

class WeatherService {
  static const String _iconBaseUrl = 'https://openweathermap.org/img/wn';
  static const String _apiKey =
      'c0d1009550c934bb96a545c2d2f38878'; // Replace with your weather API key
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather'; // Example base URL

  static Future<Weather> fetchWeatherData(
      double latitude, double longitude, DateTime selectedDate) async {
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
            date: DateTime.now(),
            condition: '',
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

  static Future<List<Weather>> fetchDailyForecast(
      double latitude, double longitude) async {
    try {
      final dailyForecastUrl = 'https://api.openweathermap.org/data/2.5/onecall'
          '?lat=$latitude&lon=$longitude&exclude=current,minutely,hourly&appid=$_apiKey';

      final dailyForecastResponse = await http.get(Uri.parse(dailyForecastUrl));

      if (dailyForecastResponse.statusCode == 200) {
        final List<Weather> dailyForecast = [];
        final dailyForecastData = json.decode(dailyForecastResponse.body);

        // Extract daily forecast data and create Weather objects
        for (var item in dailyForecastData['daily']) {
          final weather = Weather(
            temperature: (item['temp']['day'] as double) -
                273.15, // Convert from Kelvin to Celsius
            date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
            description: item['weather'][0]['description'],
            weatherIcon: await _fetchWeatherIcon(item['weather'][0]['icon']),
            feelsLike: (item['feels_like']['day'] as double) - 273.15,
            precipitation: item['rain'] != null ? item['rain'].toDouble() : 0.0,
            windSpeed: item['wind_speed'].toDouble(),
            windDirection: _getWindDirection(item['wind_deg'] as double),
            humidity: item['humidity'].toInt(),
            chanceOfRain: item['pop'].toInt(),
            aqi: 0, // You may fetch AQI from a different API or source
            uvIndex: 0, // You may fetch UV index from a different API or source
            pressure: item['pressure'].toInt(),
            visibility: item['visibility'].toDouble(),
            sunriseTime: _formatDateTime(item['sunrise'] * 1000),
            sunsetTime: _formatDateTime(item['sunset'] * 1000),
            locationName: '',
            condition: '', // You may set the location name here
          );
          dailyForecast.add(weather);
        }

        return dailyForecast;
      } else {
        throw Exception('Failed to fetch daily forecast data');
      }
    } catch (e) {
      print('Error fetching daily forecast: $e');
      throw Exception('Failed to fetch daily forecast data');
    }
  }

  static String _formatDateTime(int millisecondsSinceEpoch) {
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch * 1000);
    return DateFormat.jm().format(dateTime);
  }

  static String _getWindDirection(double degrees) {
    const List<String> directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    final index = ((degrees + 11.25) % 360 / 22.5).floor();
    return directions[index % 16];
  }

  static Future<Uint8List> _fetchWeatherIcon(String iconCode) async {
    final url = '$_iconBaseUrl/$iconCode@2x.png';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load weather icon');
    }
  }

  static Future<List<Weather>> fetchHourlyForecast(
      double latitude, double longitude, DateTime selectedDate) async {
    try {
      final hourlyForecastUrl =
          'https://api.openweathermap.org/data/2.5/onecall'
          '?lat=$latitude&lon=$longitude&exclude=current,minutely,daily&appid=$_apiKey';

      final hourlyForecastResponse =
          await http.get(Uri.parse(hourlyForecastUrl));

      if (hourlyForecastResponse.statusCode == 200) {
        final List<Weather> hourlyForecast = [];
        final hourlyForecastData = json.decode(hourlyForecastResponse.body);

        // Extract hourly forecast data and create Weather objects
        for (var item in hourlyForecastData['hourly']) {
          final weather = Weather(
            temperature: (item['temp'] as double) -
                273.15, // Convert from Kelvin to Celsius
            date: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
            description: item['weather'][0]['description'],
            weatherIcon: await _fetchWeatherIcon(item['weather'][0]['icon']),
            feelsLike: (item['feels_like'] as double) - 273.15,
            precipitation: item['rain'] != null ? item['rain'].toDouble() : 0.0,
            windSpeed: item['wind_speed'].toDouble(),
            windDirection: _getWindDirection(item['wind_deg'] as double),
            humidity: item['humidity'].toInt(),
            chanceOfRain: item['pop'].toInt(),
            aqi: 0, // You may fetch AQI from a different API or source
            uvIndex: 0, // You may fetch UV index from a different API or source
            pressure: item['pressure'].toInt(),
            visibility: item['visibility'].toDouble(),
            sunriseTime: '', // No sunrise time available for hourly forecast
            sunsetTime: '', // No sunset time available for hourly forecast
            locationName: '',
            condition: '', // You may set the location name here
          );
          hourlyForecast.add(weather);
        }

        return hourlyForecast;
      } else {
        throw Exception('Failed to fetch hourly forecast data');
      }
    } catch (e) {
      print('Error fetching hourly forecast: $e');
      throw Exception('Failed to fetch hourly forecast data');
    }
  }
}
