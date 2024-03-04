import 'package:flutter/material.dart';
import '../models/Weather.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;

  WeatherCard({required this.weather});

  IconData _getWeatherIcon() {
    String condition = weather.condition.toLowerCase();

    switch (condition) {
      case 'clear':
        return Icons.wb_sunny; // Clear sky
      case 'clouds':
        return Icons.cloud; // Cloudy
      case 'rain':
        return Icons.grain; // Rainy
      case 'thunderstorm':
        return Icons.flash_on; // Thunderstorm
      case 'drizzle':
        return Icons.grain; // Light rain or drizzle
      case 'snow':
        return Icons.ac_unit; // Snow
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return Icons.filter_drama; // Various atmospheric conditions
      default:
        return Icons.cloud_off; // Unknown or unspecified condition
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getWeatherIcon(), size: 30),
                SizedBox(width: 8),
                Text(
                  weather.locationName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              weather.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            _buildWeatherInfo(
              title: 'Temperature',
              value: '${weather.temperature.toString()}°C',
              icon: Icons.thermostat_outlined,
            ),
            _buildWeatherInfo(
              title: 'Feels Like',
              value: '${weather.feelsLike.toString()}°C',
              icon: Icons.thermostat,
            ),
            _buildWeatherInfo(
              title: 'Precipitation',
              value: '${weather.precipitation.toString()} mm',
              icon: Icons.waves_outlined,
            ),
            _buildWeatherInfo(
              title: 'Wind Speed',
              value: '${weather.windSpeed.toString()} m/s',
              icon: Icons.air_outlined,
            ),
            _buildWeatherInfo(
              title: 'Wind Direction',
              value: weather.windDirection,
              icon: Icons.navigation_outlined,
            ),
            _buildWeatherInfo(
              title: 'Humidity',
              value: '${weather.humidity.toString()}%',
              icon: Icons.opacity_outlined,
            ),
            _buildWeatherInfo(
              title: 'Chance of Rain',
              value: '${weather.chanceOfRain.toString()}%',
              icon: Icons.beach_access_outlined,
            ),
            _buildWeatherInfo(
              title: 'AQI',
              value: weather.aqi.toString(),
              icon: Icons.cloud_outlined,
            ),
            _buildWeatherInfo(
              title: 'UV Index',
              value: weather.uvIndex.toString(),
              icon: Icons.wb_sunny_outlined,
            ),
            _buildWeatherInfo(
              title: 'Pressure',
              value: '${weather.pressure.toString()} hPa',
              icon: Icons.compress_outlined,
            ),
            _buildWeatherInfo(
              title: 'Visibility',
              value: '${weather.visibility.toString()} km',
              icon: Icons.visibility_outlined,
            ),
            _buildWeatherInfo(
              title: 'Sunrise Time',
              value: _formatTime(weather.sunriseTime),
              icon: Icons.wb_sunny_outlined,
            ),
            _buildWeatherInfo(
              title: 'Sunset Time',
              value: _formatTime(weather.sunsetTime),
              icon: Icons.nightlight_round_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(
      {required String title, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
