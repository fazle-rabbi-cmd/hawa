import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Weather.dart';

class DailyForecastScreen extends StatelessWidget {
  final List<Weather> dailyForecast;

  const DailyForecastScreen({Key? key, required this.dailyForecast})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Forecast'),
      ),
      body: ListView.builder(
        itemCount: dailyForecast.length,
        itemBuilder: (context, index) {
          final weather = dailyForecast[index];
          return Card(
            child: ListTile(
              leading: Image.memory(
                weather.weatherIcon,
                width: 50,
                height: 50,
              ),
              title: Text(
                DateFormat('EEEE').format(weather.date),
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
