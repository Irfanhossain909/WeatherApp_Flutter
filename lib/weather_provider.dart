import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/utils/constants.dart';
import 'package:geolocator/geolocator.dart';

import 'models/current_weather.dart';

class WeatherProvider with ChangeNotifier {
  final _statusKey = 'status';

  double latitude = 0.0, longtude = 0.0;
  String _units = metric;
  String unitsSymble = celsius;
  CurrentResponse? currentResponse;
  ForecastResponse? forecastResponse;

  bool get hasDataLoaded => currentResponse != null && forecastResponse != null;
  void setUnit (bool status) {
    _units = status ? imperial : metric;
    unitsSymble = status ? fahrenheit : celsius;
  }

  Future<void> getWeatherData() async {
    await _getCurrentWeather();
    await _getForecastWeather();
  }

  Future<void> _getCurrentWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longtude&appid=$weatherApiKey&units=$_units';
    try {
      Response response = await get(Uri.parse(url));
      Map<String, dynamic> map = jsonDecode(response.body);
      if (response.statusCode == 200) {
        currentResponse = CurrentResponse.fromJson(map);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> _getForecastWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longtude&appid=$weatherApiKey&units=$_units';
    try {
      Response response = await get(Uri.parse(url));
      Map<String, dynamic> map = jsonDecode(response.body);
      if (response.statusCode == 200) {
        forecastResponse = ForecastResponse.fromJson(map);
        notifyListeners();
      } else {
        print(map['message']);
      }
    } catch (error) {
      print(error.toString());
    }
  }

  //using shared Prefarences and set/get methord
  Future<bool> setTempStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_statusKey, status);
  }

  Future<bool> getTempStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_statusKey) ?? false;
  }

  //shared prefference end.

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();
    latitude = position.latitude;
    longtude = position.longitude;
  }
}
