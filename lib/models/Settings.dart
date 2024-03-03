import 'package:flutter/material.dart';

enum AppTheme {
  light,
  dark,
}

class Settings {
  final String temperatureUnit;
  final String language;
  final bool notificationsEnabled;
  final int dataRefreshInterval;
  final AppTheme theme;

  Settings({
    required this.temperatureUnit,
    required this.language,
    required this.notificationsEnabled,
    required this.dataRefreshInterval,
    required this.theme,
  });
}
