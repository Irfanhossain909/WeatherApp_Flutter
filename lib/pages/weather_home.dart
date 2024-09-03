import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/customwidgets/app_background.dart';
import 'package:weather/customwidgets/bubble.dart';
import 'package:weather/models/current_weather.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/pages/setting_page.dart';
import 'package:weather/utils/constants.dart';
import 'package:weather/utils/helper_functions.dart';
import 'package:weather/weather_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  static const String routeName = '/';

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  bool isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  Future<void> getData() async {
    if(await isConnectedToInternet()){
      await context.read<WeatherProvider>().determinePosition(); // detecting location
      final status = await context
          .read<WeatherProvider>()
          .getTempStatus(); // checked status users setting activity from shared prefference.
      context
          .read<WeatherProvider>()
          .setUnit(status); //set the value and calcutale and return true or false
      context
          .read<WeatherProvider>()
          .getWeatherData(); // and restart weather data agien.
    }else{
      setState(() {
        isConnected = false;
      });
    }

  }

  Future<bool> isConnectedToInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  @override
  void didChangeDependencies() {
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if(result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile)){
        setState(() {
          isConnected = true;
          getData();
        });
      }else{
        setState(() {
          isConnected = false;
        });
      }
    });
    getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Weather App'),
        actions: [
          IconButton(
            //for navigate 1 page to another page.
            onPressed: () {
              getData();
            },
            icon: const Icon(Icons.location_on),
          ),
          IconButton(
            //for search icon navigator
            onPressed: () {
              showSearch(context: context, delegate: _CitySearchDelegate())
                  .then((city) async {
                if (city != null && city.isNotEmpty) {
                  await context
                      .read<WeatherProvider>()
                      .convertCityToLatLog(city);
                  context.read<WeatherProvider>().getWeatherData();
                }
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            //for navigate 1 page to another page.
            onPressed: () =>
                Navigator.pushNamed(context, SettingPage.routeName),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) => provider.hasDataLoaded
            ? Stack(
                children: [
                  const AppBackground(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 80.0,
                      ),
                      if(!isConnected) Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                            alignment: AlignmentDirectional.center,
                            width: double.infinity,
                            color: Colors.black45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.signal_wifi_connected_no_internet_4),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text('No Internet Connection',),
                              ],
                            )),
                      ),
                      CurrentWeatherWidget(
                        current: provider.currentResponse!,
                        symble: provider.unitsSymble,
                      ),
                      const Spacer(),
                      ForecastWeatherView(
                        items: provider.forecastResponse!.list!,
                        symble: provider.unitsSymble,
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ],
              )
            : Center(
                child: isConnected ? const CircularProgressIndicator() : const Text('No Internet Connection!!'),
              ),
      ),
    );
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}

class CurrentWeatherWidget extends StatelessWidget {
  const CurrentWeatherWidget(
      {super.key, required this.current, required this.symble});

  final CurrentResponse current;
  final String symble;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getFormattedDateTime(current.dt!),
              style: const TextStyle(fontSize: 18.0)),
          Text(
            '${current.name}, ${current.sys!.country}',
            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: getIconUrl(current.weather!.first.icon!),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  size: 40.0,
                ),
              ),
              Text(
                '${current.main!.temp!.round()}$degree$symble',
                style: const TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Feels Like${current.main!.feelsLike!.round()}$degree$symble',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                '${current.weather!.first.main}-${current.weather!.first.description}',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Humidity ${current.main!.humidity}'),
                const Bubble(),
                Text('Pressure ${current.main!.pressure}'),
                const Bubble(),
                Text('Visibility ${current.visibility}km'),
                const Bubble(),
                Text(
                    'Sunrice ${getFormattedDateTime(current.sys!.sunrise!, pattern: 'hh:mm a')}'),
                const Bubble(),
                Text(
                    'Sunrice ${getFormattedDateTime(current.sys!.sunset!, pattern: 'hh:mm a')}'),
                const Bubble(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ForecastWeatherView extends StatelessWidget {
  const ForecastWeatherView(
      {super.key, required this.items, required this.symble});

  final List<ForeCastItem> items;
  final String symble;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 130.0,
            child: Card(
              color: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Text(getFormattedDateTime(item.dt!,
                          pattern: 'EE hh:mm a')),
                      CachedNetworkImage(
                        imageUrl: getIconUrl(item.weather!.first.icon!),
                        width: 35.0,
                        height: 35.0,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                      ),
                      Text(
                        '${item.main!.temp!}$degree$symble',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Max : ${item.main!.tempMax}$degree$symble',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Max : ${item.main!.tempMin}$degree$symble',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Humidity ${item.main!.humidity}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text('Feel Like ${item.main!.feelsLike}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? majorCities
        : majorCities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final city = filteredList[index];
          return ListTile(
            onTap: () {
              close(context, city);
            },
            title: Text(city),
          );
        });
  }

}



