import 'package:flutter/material.dart';
import '../models/Weather.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;

  WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperature: ${weather.temperature.toString()}°',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('Feels Like: ${weather.feelsLike.toString()}°'),
            SizedBox(height: 5),
            Text('Precipitation: ${weather.precipitation.toString()} mm'),
            SizedBox(height: 5),
            Text('Wind Speed: ${weather.windSpeed.toString()} m/s'),
            SizedBox(height: 5),
            Text('Wind Direction: ${weather.windDirection}'),
            SizedBox(height: 5),
            Text('Humidity: ${weather.humidity.toString()}%'),
            SizedBox(height: 5),
            Text('Chance of Rain: ${weather.chanceOfRain.toString()}%'),
            SizedBox(height: 5),
            Text('AQI: ${weather.aqi.toString()}'),
            SizedBox(height: 5),
            Text('UV Index: ${weather.uvIndex.toString()}'),
            SizedBox(height: 5),
            Text('Pressure: ${weather.pressure.toString()} hPa'),
            SizedBox(height: 5),
            Text('Visibility: ${weather.visibility.toString()} km'),
            SizedBox(height: 5),
            Text('Sunrise Time: ${weather.sunriseTime}'),
            SizedBox(height: 5),
            Text('Sunset Time: ${weather.sunsetTime}'),
          ],
        ),
      ),
    );
  }
}
