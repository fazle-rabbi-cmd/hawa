import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/WeatherService.dart';
import 'HourlyForecastScreen.dart';
import 'SettingsScreen.dart';
import 'SearchScreen.dart';
import 'DailyForecastScreen.dart';
import '../models/crop.dart'; // Import the Crop model

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

  // Function to filter crops based on current weather conditions
  List<Crop> filterCropsByWeather(Weather weather) {
    final List<Crop> crops = [
      Crop(
          name: 'Tomatoes',
          temperatureRange: [20, 30],
          humidityRange: [50, 70]),
      Crop(
          name: 'Lettuce', temperatureRange: [10, 20], humidityRange: [60, 80]),
      Crop(name: 'Corn', temperatureRange: [25, 35], humidityRange: [40, 60]),
      Crop(
          name: 'Carrots', temperatureRange: [15, 25], humidityRange: [40, 60]),
      Crop(
          name: 'Potatoes',
          temperatureRange: [10, 20],
          humidityRange: [50, 70]),
      // Add more crops here
    ];

    return crops.where((crop) {
      final temp = weather.temperature;
      final humidity = weather.humidity;
      return temp >= crop.temperatureRange[0] &&
          temp <= crop.temperatureRange[1] &&
          humidity >= crop.humidityRange[0] &&
          humidity <= crop.humidityRange[1];
    }).toList();
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
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final weather = snapshot.data!;
              final List<Crop> suggestedCrops = filterCropsByWeather(weather);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeatherDisplay(weather),
                      const SizedBox(height: 20),
                      if (suggestedCrops.isNotEmpty) ...[
                        Text(
                          'Suggested Crops:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestedCrops.length,
                            itemBuilder: (context, index) {
                              final crop = suggestedCrops[index];
                              return Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(crop.name),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Last Updated: ${DateFormat.yMd().add_jm().format(_lastRefreshedTime)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.caption!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _navigateToHourlyForecastScreen(context),
            child: const Icon(Icons.access_time),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _navigateToDailyForecastScreen(context),
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDisplay(Weather weather) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weather.locationName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weather.description,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Feels Like ${weather.feelsLike.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherInfoItem('Precipitation',
                        '${weather.precipitation}', Icons.cloud),
                    _buildWeatherInfoItem(
                        'Wind Speed', '${weather.windSpeed} m/s', Icons.toys),
                    _buildWeatherInfoItem(
                        'Humidity', '${weather.humidity}%', Icons.water_drop),
                    _buildWeatherInfoItem('Chance of Rain',
                        '${weather.chanceOfRain}%', Icons.grain),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherInfoItem(
                        'AQI', '${weather.aqi}', Icons.cloud_queue),
                    _buildWeatherInfoItem(
                        'UV Index', '${weather.uvIndex}', Icons.wb_sunny),
                    _buildWeatherInfoItem(
                        'Pressure', '${weather.pressure} hPa', Icons.compress),
                    _buildWeatherInfoItem('Visibility',
                        '${weather.visibility} km', Icons.visibility),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherInfoItem(
                    'Sunrise', weather.sunriseTime, Icons.wb_sunny_outlined),
                _buildWeatherInfoItem(
                    'Sunset', weather.sunsetTime, Icons.nightlight_round),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoItem(String title, String value, IconData iconData) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
