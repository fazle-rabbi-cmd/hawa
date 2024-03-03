import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/WeatherService.dart';
import 'SettingsScreen.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Weather> _weatherData;
  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _weatherData = _fetchWeatherData();
  }

  Future<Weather> _fetchWeatherData() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Fetch weather data using current location coordinates
      Weather weather =
          await WeatherService.fetchWeatherData(latitude, longitude);
      setState(() {
        _weatherData = Future.value(weather);
      });
      return weather; // Return the fetched weather data
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching current location: $e');
      }
      // Handle error gracefully, e.g., show an error message to the user
      rethrow; // Rethrow the exception to propagate it upwards
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              Weather? selectedWeather = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
              if (selectedWeather != null) {
                setState(() {
                  _weatherData = Future.value(selectedWeather);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings screen
              _navigateToSettingsScreen(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<Weather>(
        future: _weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print('Error fetching weather data: ${snapshot.error}');
            }
            return const Center(child: Text('Failed to fetch weather data'));
          } else {
            if (kDebugMode) {
              print('Weather data received: ${snapshot.data}');
            }
            return SingleChildScrollView(
              child: _buildWeatherDisplay(snapshot.data!),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeatherDisplay(Weather weather) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Wrap the Image.memory widget with a try-catch block to handle decoding errors

              Image.memory(
                weather.weatherIcon,
                width: 48,
                height: 48,
              ),

              const SizedBox(width: 8),
              Text(
                weather.description,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildWeatherInfoItem(
            'Location',
            weather
                .locationName, // Assume Weather has a locationName property containing the location name
            Icons.location_on,
          ),
          _buildWeatherInfoItem(
            'Temperature',
            '${weather.temperature.toStringAsFixed(1)}°C',
            Icons.thermostat,
          ),
          _buildWeatherInfoItem(
            'Feels Like',
            '${weather.feelsLike.toStringAsFixed(1)}°C',
            Icons.thermostat,
          ),
          _buildWeatherInfoItem(
            'Precipitation',
            '${weather.precipitation}',
            Icons.cloud,
          ),
          _buildWeatherInfoItem(
            'Wind Speed',
            '${weather.windSpeed} m/s',
            Icons.toys,
          ),
          _buildWeatherInfoItem(
            'Wind Direction',
            weather.windDirection,
            Icons.navigation,
          ),
          _buildWeatherInfoItem(
            'Humidity',
            '${weather.humidity}%',
            Icons.water_drop,
          ),
          _buildWeatherInfoItem(
            'Chance of Rain',
            '${weather.chanceOfRain}%',
            Icons.grain,
          ),
          _buildWeatherInfoItem(
            'AQI',
            '${weather.aqi}',
            Icons.cloud_queue,
          ),
          _buildWeatherInfoItem(
            'UV Index',
            '${weather.uvIndex}',
            Icons.wb_sunny,
          ),
          _buildWeatherInfoItem(
            'Pressure',
            '${weather.pressure} hPa',
            Icons.compress,
          ),
          _buildWeatherInfoItem(
            'Visibility',
            '${weather.visibility} km',
            Icons.visibility,
          ),
          _buildWeatherInfoItem(
            'Sunrise Time',
            weather.sunriseTime,
            Icons.wb_sunny_outlined,
          ),
          _buildWeatherInfoItem(
            'Sunset Time',
            weather.sunsetTime,
            Icons.nightlight_round,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoItem(String title, String value, IconData iconData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
