import 'package:flutter/material.dart';
import '../models/Weather.dart';

class WeatherCard extends StatefulWidget {
  final Weather weather;

  WeatherCard({required this.weather});

  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.condition != widget.weather.condition) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  IconData _getWeatherIcon() {
    String condition = widget.weather.condition.toLowerCase();

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

  Color _getWeatherColor() {
    String condition = widget.weather.condition.toLowerCase();

    switch (condition) {
      case 'clear':
        return Colors.yellow[200]!; // Clear sky (Yellow)
      case 'clouds':
        return Colors.grey[400]!; // Cloudy (Grey)
      case 'rain':
        return Colors.blue[300]!; // Rainy (Blue)
      case 'thunderstorm':
        return Colors.deepPurple[400]!; // Thunderstorm (Deep Purple)
      case 'drizzle':
        return Colors.blue[200]!; // Light rain or drizzle (Light Blue)
      case 'snow':
        return Colors.white; // Snow (White)
      default:
        return Colors.grey; // Unknown or unspecified condition (Grey)
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        color: _getWeatherColor(),
        child: ExpansionTile(
          leading: Icon(
            _getWeatherIcon(),
            size: 30,
            color: Colors.white,
          ),
          title: Text(
            widget.weather.locationName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description: ${widget.weather.description}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  _buildWeatherInfo(
                    title: 'Temperature',
                    value: '${widget.weather.temperature.toString()}°C',
                    icon: Icons.thermostat_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Feels Like',
                    value: '${widget.weather.feelsLike.toString()}°C',
                    icon: Icons.thermostat,
                  ),
                  _buildWeatherInfo(
                    title: 'Precipitation',
                    value: '${widget.weather.precipitation.toString()} mm',
                    icon: Icons.waves_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Wind Speed',
                    value: '${widget.weather.windSpeed.toString()} m/s',
                    icon: Icons.air_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Wind Direction',
                    value: widget.weather.windDirection,
                    icon: Icons.navigation_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Humidity',
                    value: '${widget.weather.humidity.toString()}%',
                    icon: Icons.opacity_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Chance of Rain',
                    value: '${widget.weather.chanceOfRain.toString()}%',
                    icon: Icons.beach_access_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'AQI',
                    value: widget.weather.aqi.toString(),
                    icon: Icons.cloud_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'UV Index',
                    value: widget.weather.uvIndex.toString(),
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Pressure',
                    value: '${widget.weather.pressure.toString()} hPa',
                    icon: Icons.compress_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Visibility',
                    value: '${widget.weather.visibility.toString()} km',
                    icon: Icons.visibility_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Sunrise Time',
                    value: _formatTime(widget.weather.sunriseTime),
                    icon: Icons.wb_sunny_outlined,
                  ),
                  _buildWeatherInfo(
                    title: 'Sunset Time',
                    value: _formatTime(widget.weather.sunsetTime),
                    icon: Icons.nightlight_round_outlined,
                  ),
                ],
              ),
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
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.white),
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
