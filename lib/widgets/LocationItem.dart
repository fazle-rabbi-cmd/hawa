import 'package:flutter/material.dart';

class LocationItem extends StatelessWidget {
  final String locationName;
  final VoidCallback onTap;

  LocationItem({
    required this.locationName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(locationName),
      onTap: onTap,
    );
  }
}
