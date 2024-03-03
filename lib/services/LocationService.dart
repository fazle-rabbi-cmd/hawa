import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    try {
      // Request permission to access location
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  static Future<List<String>?> searchLocations(String query) async {
    try {
      // Use Geocoding API to search for locations based on the query
      List<Placemark>? placemarks =
          await GeocodingPlatform.instance?.placemarkFromAddress(query);

      // Extract location names from placemarks
      List<String>? locations = placemarks?.map((placemark) {
        return placemark.name ?? '';
      }).toList();

      return locations;
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }
}
