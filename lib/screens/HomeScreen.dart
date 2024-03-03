import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/WeatherService.dart';
import 'SettingsScreen.dart';
import 'SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.isDarkTheme,
    required this.toggleTheme,
  }) : super(key: key);

  final bool isDarkTheme;
  final void Function(bool isDark) toggleTheme;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Weather> _weatherData;
  late DateTime _lastRefreshedTime;

  @override
  void initState() {
    super.initState();
    _lastRefreshedTime = DateTime.now();
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
      Weather? weather =
          await WeatherService.fetchWeatherData(latitude, longitude);

      if (weather != null) {
        setState(() {
          _weatherData = Future.value(weather);
          _lastRefreshedTime = DateTime.now();
        });
        return weather; // Return the fetched weather data
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      // Handle error gracefully
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      rethrow;
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _weatherData = _fetchWeatherData();
    });
  }

  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hawa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
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
              _navigateToSettingsScreen(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshWeather(),
        child: FutureBuilder<Weather>(
          future: _weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final weather = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherDisplay(weather),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Last Updated: ${DateFormat.yMd().add_jm().format(_lastRefreshedTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.caption!.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
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
          const SizedBox(height: 20),
          _buildWeatherInfoItem(
              'Location', weather.locationName, Icons.location_on),
          _buildWeatherInfoItem('Temperature',
              '${weather.temperature.toStringAsFixed(1)}°C', Icons.thermostat),
          _buildWeatherInfoItem('Feels Like',
              '${weather.feelsLike.toStringAsFixed(1)}°C', Icons.thermostat),
          _buildWeatherInfoItem(
              'Precipitation', '${weather.precipitation}', Icons.cloud),
          _buildWeatherInfoItem(
              'Wind Speed', '${weather.windSpeed} m/s', Icons.toys),
          _buildWeatherInfoItem(
              'Wind Direction', weather.windDirection, Icons.navigation),
          _buildWeatherInfoItem(
              'Humidity', '${weather.humidity}%', Icons.water_drop),
          _buildWeatherInfoItem(
              'Chance of Rain', '${weather.chanceOfRain}%', Icons.grain),
          _buildWeatherInfoItem('AQI', '${weather.aqi}', Icons.cloud_queue),
          _buildWeatherInfoItem(
              'UV Index', '${weather.uvIndex}', Icons.wb_sunny),
          _buildWeatherInfoItem(
              'Pressure', '${weather.pressure} hPa', Icons.compress),
          _buildWeatherInfoItem(
              'Visibility', '${weather.visibility} km', Icons.visibility),
          _buildWeatherInfoItem(
              'Sunrise Time', weather.sunriseTime, Icons.wb_sunny_outlined),
          _buildWeatherInfoItem(
              'Sunset Time', weather.sunsetTime, Icons.nightlight_round),
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
