import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Weather.dart';

class HourlyForecastScreen extends StatelessWidget {
  final List<Weather> hourlyForecast;

  const HourlyForecastScreen({Key? key, required this.hourlyForecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hourly Forecast'),
      ),
      body: ListView.builder(
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final weather = hourlyForecast[index];
          return Card(
            child: ListTile(
              leading: Image.memory(
                weather.weatherIcon,
                width: 50,
                height: 50,
              ),
              title: Text(
                DateFormat('HH:mm').format(weather.date),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weather.description),
                  Text('${weather.temperature.toStringAsFixed(1)}°C'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
