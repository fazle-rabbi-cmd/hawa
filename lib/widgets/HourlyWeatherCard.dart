import 'package:flutter/material.dart';
import '../models/Weather.dart';
import 'package:intl/intl.dart';

class HourlyWeatherCard extends StatelessWidget {
  final Weather weather;

  const HourlyWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('h:mm a').format(weather.date),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Image.memory(
              weather.weatherIcon,
              width: 32,
              height: 32,
            ),
            SizedBox(height: 8),
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              weather.description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
