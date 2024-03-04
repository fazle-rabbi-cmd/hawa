import '../models/Weather.dart';
import '../models/crop.dart';

List<Crop> filterCropsByWeather(Weather weather) {
  final List<Crop> crops = [
    Crop(name: 'Tomatoes', temperatureRange: [20, 30], humidityRange: [50, 70]),
    Crop(name: 'Lettuce', temperatureRange: [10, 20], humidityRange: [60, 80]),
    Crop(name: 'Corn', temperatureRange: [25, 35], humidityRange: [40, 60]),
    Crop(name: 'Carrots', temperatureRange: [15, 25], humidityRange: [40, 60]),
    Crop(name: 'Potatoes', temperatureRange: [10, 20], humidityRange: [50, 70]),
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
