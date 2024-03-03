import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/Weather.dart';
import '../services/LocationService.dart';
import '../services/WeatherService.dart';
import 'package:hawa/widgets/LocationItem.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchLocations);
  }

  void _searchLocations() async {
    String query = _searchController.text;
    List<String>? results = await LocationService.searchLocations(query);
    setState(() {
      _searchResults = results ?? [];
    });
  }

  void _handleSearch() async {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      try {
        Weather? weather =
            await WeatherService.fetchWeatherDataForLocation(query);
        if (weather != null) {
          // Return the weather data to the previous screen (likely your home screen)
          Navigator.of(context).pop(weather);
        } else {
          _showDialog(
            'Weather Data Unavailable',
            'No weather data available for the location: $query. Please try another location.',
          );
        }
      } catch (e) {
        _showErrorDialog(
          'Error Fetching Weather',
          'Failed to fetch weather data for $query. Please try again later.',
        );
        if (kDebugMode) {
          print('Error fetching weather data for location: $e');
        }
      }
    } else {
      _showDialog(
          'Empty Search Query', 'Please enter a location name to search.');
    }
  }

  void _handleSelectedLocation(String locationName) async {
    try {
      // Fetch weather data using the selected location name
      Weather? weather =
          await WeatherService.fetchWeatherDataForLocation(locationName);
      if (weather != null) {
        // Return the selected weather data
        Navigator.pop(context, weather);
      } else {
        _showErrorDialog(
          'Error Fetching Weather',
          'Failed to fetch weather data for $locationName. Please try again later.',
        );
      }
    } catch (e) {
      // Handle error fetching weather data
      _showErrorDialog(
        'Error Fetching Weather',
        'Failed to fetch weather data for $locationName. Please try again later.',
      );
      if (kDebugMode) {
        print('Error fetching weather data for location: $e');
      }
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleSetCurrentLocation() async {
    try {
      print('Fetching current location...');
      Position? currentPosition = await LocationService.getCurrentLocation();
      if (currentPosition != null) {
        print('Current position: $currentPosition');
        String currentLocation = await getLocationName(currentPosition);
        print('Current location name: $currentLocation');
        if (currentLocation.isNotEmpty) {
          Weather? weather =
              await WeatherService.fetchWeatherDataForLocation(currentLocation);
          if (weather != null) {
            print('Weather data for current location: $weather');
            Navigator.pop(context, weather);
          } else {
            _showErrorDialog(
              'Error Fetching Weather',
              'Failed to fetch weather data for current location.',
            );
          }
        } else {
          _showErrorDialog(
            'Location Not Available',
            'Unable to fetch current location name.',
          );
        }
      } else {
        _showErrorDialog(
          'Location Not Available',
          'Failed to retrieve current location.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'Error Fetching Weather',
        'Failed to fetch weather data for current location. Error: $e',
      );
      if (kDebugMode) {
        print('Error fetching weather data for current location: $e');
      }
    }
  }

  Future<String> getLocationName(Position currentPosition) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    return placemarks.first.name ?? 'Unknown';
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    _showDialog(title, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Locations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _handleSearch(),
                    decoration: InputDecoration(
                      hintText: 'Enter location name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchLocations();
                        },
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return LocationItem(
                  locationName: _searchResults[index],
                  onTap: () {
                    _handleSelectedLocation(_searchResults[index]);
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _handleCancel,
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _handleSetCurrentLocation,
                child: const Text('Set Current Location'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
