// models/crop.dart

class Crop {
  final String name;
  final List<int> temperatureRange;
  final List<int> humidityRange;

  Crop({
    required this.name,
    required this.temperatureRange,
    required this.humidityRange,
  });
}
