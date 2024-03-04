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
                  SizedBox(height: 4),
                  _buildWeatherInfoRow('Temperature',
                      '${weather.temperature.toStringAsFixed(1)}°C'),
                  _buildWeatherInfoRow('Feels Like',
                      '${weather.feelsLike.toStringAsFixed(1)}°C'),
                  _buildWeatherInfoRow(
                      'Precipitation', '${weather.precipitation} mm/h'),
                  _buildWeatherInfoRow(
                      'Wind Speed', '${weather.windSpeed} m/s'),
                  _buildWeatherInfoRow(
                      'Wind Direction', '${weather.windDirection}°'),
                  _buildWeatherInfoRow('Humidity', '${weather.humidity}%'),
                  _buildWeatherInfoRow(
                      'Chance of Rain', '${weather.chanceOfRain}%'),
                  _buildWeatherInfoRow('AQI', '${weather.aqi}'),
                  _buildWeatherInfoRow('UV Index', '${weather.uvIndex}'),
                  _buildWeatherInfoRow('Pressure', '${weather.pressure} hPa'),
                  _buildWeatherInfoRow(
                      'Visibility', '${weather.visibility} km'),
                  _buildWeatherInfoRow('Sunrise Time', weather.sunriseTime),
                  _buildWeatherInfoRow('Sunset Time', weather.sunsetTime),
                  SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherInfoRow(String title, String value) {
    return Row(
      children: [
        Text(
          '$title: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}
