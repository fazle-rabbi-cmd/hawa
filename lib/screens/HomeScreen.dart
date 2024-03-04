import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/WeatherService.dart';
import 'package:hawa/screens/DateSelectionScreen.dart';
import 'HourlyForecastScreen.dart';
import 'SettingsScreen.dart';
import 'SearchScreen.dart';
import 'DailyForecastScreen.dart';
import '../models/crop.dart';
import '../widgets/WeatherCard.dart';
import '../helpers/crop_suggestion.dart'; // Import the crop suggestion logic

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
  late Future<Weather?> _weatherData;
  late Future<List<Weather>?> _hourlyForecastData;
  late DateTime _lastRefreshedTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _lastRefreshedTime = DateTime.now();
    _selectedDate = DateTime.now();
    _weatherData = _fetchWeatherData(_selectedDate);
    _hourlyForecastData = _fetchHourlyForecastData(_selectedDate);
  }

  Future<Weather?> _fetchWeatherData(DateTime selectedDate) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      Weather? weather = await WeatherService.fetchWeatherData(
          latitude, longitude, selectedDate);

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
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      // Handle error gracefully
      return null;
    }
  }

  Future<List<Weather>?> _fetchHourlyForecastData(DateTime selectedDate) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      List<Weather>? hourlyForecast = await WeatherService.fetchHourlyForecast(
          latitude, longitude, selectedDate);

      return hourlyForecast;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching hourly forecast data: $e');
      }
      // Handle error gracefully
      return null;
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _weatherData = _fetchWeatherData(_selectedDate);
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

      List<Weather>? dailyForecast =
          await WeatherService.fetchDailyForecast(latitude, longitude);

      if (dailyForecast != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyForecastScreen(
              dailyForecast: dailyForecast,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to daily forecast screen: $e');
      }
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

      List<Weather>? hourlyForecast = await WeatherService.fetchHourlyForecast(
          latitude, longitude, _selectedDate);

      if (hourlyForecast != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HourlyForecastScreen(
              hourlyForecast: hourlyForecast,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching hourly forecast data: $e');
      }
      // Handle error gracefully
    }
  }

  void _navigateToDateSelectionScreen(BuildContext context) async {
    DateTime? selectedDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSelectionScreen(
          onDateSelected: (selectedDate) async {
            _selectedDate = selectedDate;
            _weatherData = _fetchWeatherData(_selectedDate);
            _hourlyForecastData = _fetchHourlyForecastData(_selectedDate);
            Navigator.pop(context);
          },
          initialDate: _selectedDate,
        ),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _weatherData = _fetchWeatherData(_selectedDate);
        _hourlyForecastData = _fetchHourlyForecastData(_selectedDate);
      });
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
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _navigateToDateSelectionScreen(context),
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
        child: FutureBuilder<Weather?>(
          future: _weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text('Error: Unable to fetch weather data'),
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
                      WeatherCard(
                          weather: weather), // Use WeatherCard widget here
                      const SizedBox(height: 20),
                      if (suggestedCrops.isNotEmpty) ...[
                        const Text(
                          'Suggested Crops:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
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
                      FutureBuilder<List<Weather>?>(
                        future: _hourlyForecastData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return const Center(
                              child:
                                  Text('Error fetching hourly forecast data'),
                            );
                          } else {
                            List<Weather> hourlyForecast = snapshot.data!;
                            return HourlyForecastScreen(
                                hourlyForecast: hourlyForecast);
                          }
                        },
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
            heroTag: 'hourly_forecast',
            onPressed: () => _navigateToHourlyForecastScreen(context),
            child: const Icon(Icons.access_time),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'daily_forecast',
            onPressed: () => _navigateToDailyForecastScreen(context),
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }
}
