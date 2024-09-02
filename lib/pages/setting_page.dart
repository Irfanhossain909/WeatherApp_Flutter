import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  static const String routeName = '/settings';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isOn = false;
  @override
  void didChangeDependencies() {
    context.read<WeatherProvider>().getTempStatus()
    .then((value) {
      setState(() {
        isOn = value;
      });
    });
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          SwitchListTile(
            value: isOn,
            onChanged: (temp_value) async{
              setState(() {
                isOn = temp_value;
              });
              await context.read<WeatherProvider>().setTempStatus(temp_value);
              context.read<WeatherProvider>().setUnit(temp_value);
              context.read<WeatherProvider>().getWeatherData();
            },
            title: const Text('Show temperature in fahrenheit'),
            subtitle: const Text('Default is Celsius'),
          ),
        ],
      ),
    );
  }
}
