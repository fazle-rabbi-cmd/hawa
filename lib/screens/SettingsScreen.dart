import 'package:flutter/material.dart';
import 'package:hawa/utils/Constants.dart';
import 'package:hawa/widgets/SettingsItem.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedTemperatureUnit;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _selectedTemperatureUnit = Constants.defaultTemperatureUnit;
    _loadTemperatureUnit();
    _loadTheme();
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTemperatureUnit = prefs.getString('temperatureUnit') ??
          Constants.defaultTemperatureUnit;
    });
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: [
            SettingsItem(
              title: 'Temperature Unit',
              subtitle: _selectedTemperatureUnit,
              icon: Icons.thermostat,
              onTap: () {
                _showTemperatureUnitDialog(context);
              },
            ),
            SettingsItem(
              title: 'Language',
              subtitle: Constants.defaultLanguage,
              icon: Icons.language,
              onTap: () {
                // Handle onTap action for language setting
              },
            ),
            SettingsItem(
              title: 'Notifications',
              subtitle: Constants.defaultNotificationsEnabled
                  ? 'Enabled'
                  : 'Disabled',
              icon: Constants.defaultNotificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_off,
              onTap: () {
                // Handle onTap action for notifications setting
              },
            ),
            SettingsItem(
              title: 'Data Refresh Interval',
              subtitle: '${Constants.defaultDataRefreshInterval} seconds',
              icon: Icons.refresh,
              onTap: () {
                // Handle onTap action for data refresh interval setting
              },
            ),
            SettingsItem(
              title: 'Theme',
              subtitle: _isDarkTheme ? 'Dark' : 'Light',
              icon: Icons.color_lens,
              onTap: () {
                _toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTemperatureUnitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Temperature Unit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildTemperatureUnitOption(context, 'Celsius'),
                _buildTemperatureUnitOption(context, 'Fahrenheit'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemperatureUnitOption(BuildContext context, String unit) {
    return ListTile(
      title: Text(unit),
      onTap: () async {
        Navigator.of(context).pop(); // Close the dialog
        setState(() {
          _selectedTemperatureUnit = unit;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temperatureUnit', unit);
      },
    );
  }

  void _toggleTheme() async {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
  }
}
