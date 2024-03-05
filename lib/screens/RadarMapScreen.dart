import 'package:flutter/material.dart';

class RadarMapScreen extends StatelessWidget {
  final String radarMapImageUrl; // URL for radar map image
  final String satelliteMapImageUrl; // URL for satellite map image

  RadarMapScreen({
    required this.radarMapImageUrl,
    required this.satelliteMapImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radar & Satellite Maps'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              radarMapImageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Image.network(
              satelliteMapImageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
