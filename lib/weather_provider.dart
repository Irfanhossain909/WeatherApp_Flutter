import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/utils/constants.dart';
import 'package:geolocator/geolocator.dart';

import 'models/current_weather.dart';

class WeatherProvider with ChangeNotifier {
  final _statusKey = 'status';

  double latitude = 0.0, longitude = 0.0;
  String _units = metric;
  String unitSymbol = celsius;
  CurrentResponse? currentResponse;
  ForecastResponse? forecastResponse;

  bool get hasDataLoaded => currentResponse != null && forecastResponse != null;
  void setUnit (bool status) {
    _units = status ? imperial : metric;
    unitSymbol = status ? fahrenheit : celsius;
  }

  Future<void> getWeatherData() async {
    await _getCurrentWeather();
    await _getForecastWeather();
  }

  Future<void> _getCurrentWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$_units';
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
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$_units';
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

  Future<bool> setTempStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_statusKey, status);
  }

  Future<bool> getTempStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_statusKey) ?? false;
  }


  Future<void> convertCityToLatLog (String city) async {
    try {
      final locationList = await geo.locationFromAddress(city);
      if(locationList.isNotEmpty){
        final location = locationList.first;
        latitude = location.latitude;
        longitude = location.longitude;
      }

    }catch(error) {
      print(error);
    }
  }

  Future<LocationDetectionStatus> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //return Future.error('Location services are disabled.');
      //_errorMessage = 'Location services are disabled.';
      return LocationDetectionStatus.locationServiceDisabled;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //return Future.error('Location permissions are denied');
        //_errorMessage = 'Location permissions are denied';
        return LocationDetectionStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      //_errorMessage = 'Location permissions are permanently denied, we cannot request permissions.';
      return LocationDetectionStatus.permissionDeniedForever;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: _getLocationSettings(),
    );
    latitude = position.latitude;
    longitude = position.longitude;
    notifyListeners();
    return LocationDetectionStatus.success;
  }

  Future<bool> openLocationServiceSettings() {
    return Geolocator.openLocationSettings();
  }

  LocationSettings _getLocationSettings() {
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
            "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else if (kIsWeb) {
      locationSettings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        maximumAge: const Duration(minutes: 5),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    return locationSettings;
  }
}
