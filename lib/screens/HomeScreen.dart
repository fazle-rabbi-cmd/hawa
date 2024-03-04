import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/WeatherService.dart';
import 'HourlyForecastScreen.dart';
import 'SettingsScreen.dart';
import 'SearchScreen.dart';
import 'DailyForecastScreen.dart';
import 'package:hawa/widgets/HourlyWeatherCard.dart';

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
  late Future<List<Weather>> _hourlyForecastData;
  late DateTime _lastRefreshedTime;

  @override
  void initState() {
    super.initState();
    _lastRefreshedTime = DateTime.now();
    _weatherData = _fetchWeatherData();
    _hourlyForecastData = _fetchHourlyForecastData();
  }

  Future<Weather> _fetchWeatherData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      Weather? weather =
          await WeatherService.fetchWeatherData(latitude, longitude);

      if (weather != null) {
        setState(() {
          _weatherData = Future.value(weather);
          _lastRefreshedTime = DateTime.now();
        });
        return weather;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      rethrow;
    }
  }

  Future<List<Weather>> _fetchHourlyForecastData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      List<Weather> hourlyForecast =
          await WeatherService.fetchHourlyForecast(latitude, longitude);

      return hourlyForecast;
    } catch (e) {
      print('Error fetching hourly forecast data: $e');
      throw Exception('Failed to fetch hourly forecast data');
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

  void _navigateToDailyForecastScreen(BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      List<Weather> dailyForecast =
          await WeatherService.fetchDailyForecast(latitude, longitude);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyForecastScreen(
            dailyForecast: dailyForecast,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to daily forecast screen: $e');
      // Handle error gracefully
    }
  }

  void _navigateToHourlyForecastScreen(BuildContext context) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      List<Weather> hourlyForecast =
          await WeatherService.fetchHourlyForecast(latitude, longitude);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HourlyForecastScreen(
            hourlyForecast: hourlyForecast,
          ),
        ),
      );
    } catch (e) {
      print('Error fetching hourly forecast data: $e');
      // Handle error gracefully
    }
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
                    _buildHourlyWeatherList(),
                    const SizedBox(height: 20),
                    _buildDailyWeatherCard(weather),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToHourlyForecastScreen(context),
        child: const Icon(Icons.access_time),
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

  Widget _buildDailyWeatherCard(Weather weather) {
    return Card(
      child: InkWell(
        onTap: () => _navigateToDailyForecastScreen(context),
        child: ListTile(
          title: const Text('Daily Weather Info'),
          subtitle: Text(
            'Temperature: ${weather.temperature.toStringAsFixed(1)}°C',
          ),
          trailing: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Widget _buildHourlyWeatherList() {
    return FutureBuilder<List<Weather>>(
      future: _hourlyForecastData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final hourlyForecast = snapshot.data!;
          return SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecast.length,
              itemBuilder: (context, index) {
                final weather = hourlyForecast[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: HourlyWeatherCard(weather: weather),
                );
              },
            ),
          );
        }
      },
    );
  }
}
