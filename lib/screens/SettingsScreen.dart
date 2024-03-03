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

  @override
  void initState() {
    super.initState();
    _selectedTemperatureUnit = Constants.defaultTemperatureUnit;
    _loadTemperatureUnit(); // Load temperature unit from SharedPreferences when the screen initializes
  }

  Future<void> _loadTemperatureUnit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTemperatureUnit = prefs.getString('temperatureUnit') ??
          Constants.defaultTemperatureUnit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            subtitle:
                Constants.defaultNotificationsEnabled ? 'Enabled' : 'Disabled',
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
            subtitle: Constants.defaultTheme,
            icon: Icons.color_lens,
            onTap: () {
              // Handle onTap action for theme setting
            },
          ),
        ],
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
          _selectedTemperatureUnit =
              unit; // Update the selected temperature unit
        });
        // Save the selected temperature unit to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('temperatureUnit', unit);
      },
    );
  }
}
