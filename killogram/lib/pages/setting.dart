import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTimeZone = 'WIB';
  final List<String> _timeZones = ['WIB', 'WITA', 'WIT', 'London'];

  @override
  void initState() {
    super.initState();
    _loadSelectedTimeZone();
  }

  Future<void> _loadSelectedTimeZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTimeZone = prefs.getString('selectedTimeZone') ?? 'WIB';
    });
  }

  Future<void> _saveSelectedTimeZone(String timeZone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTimeZone', timeZone);
    setState(() {
      _selectedTimeZone = timeZone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: _timeZones.length,
        itemBuilder: (context, index) {
          final timeZone = _timeZones[index];
          return RadioListTile<String>(
            title: Text(timeZone),
            value: timeZone,
            groupValue: _selectedTimeZone,
            onChanged: (value) {
              if (value != null) {
                _saveSelectedTimeZone(value);
              }
            },
          );
        },
      ),
    );
  }
}
