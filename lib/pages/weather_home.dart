import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/customwidgets/app_background.dart';
import 'package:weather/customwidgets/bubble.dart';
import 'package:weather/models/current_weather.dart';
import 'package:weather/models/forecast_weather.dart';
import 'package:weather/utils/constants.dart';
import 'package:weather/utils/helper_functions.dart';
import 'package:weather/weather_provider.dart';

class WeatherHome extends StatelessWidget {
  const WeatherHome({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<WeatherProvider>().determinePosition().then((value) {
      context.read<WeatherProvider>().getWeatherData();
    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Weather App'),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) => provider.hasDataLoaded
            ? Stack(
                children: [
                  const AppBackground(),
                  Column(
                    children: [
                      CurrentWeatherWidget(
                        current: provider.currentResponse!,
                        symble: provider.unitsSymble,
                      ),
                      const Spacer(),
                      ForecastWeatherView(
                        items: provider.forecastResponse!.list!,
                        symble: provider.unitsSymble,
                      ),
                      SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
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
          const SizedBox(
            height: 80.0,
          ),
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
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error, size: 40.0,),
              ),
              Text(
                '${current.main!.temp!.round()}$degree$symble',
                style: TextStyle(fontSize: 80.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Feels Like${current.main!.feelsLike!.round()}$degree$symble',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text(
                '${current.weather!.first.main}-${current.weather!.first.description}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
                        placeholder: (context, url) => const CircularProgressIndicator(),
                      ),
                      Text(
                        '${item.main!.temp!}$degree$symble',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Max : ${item.main!.tempMax}$degree$symble',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Max : ${item.main!.tempMin}$degree$symble',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Humidity ${item.main!.humidity}%',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Feel Like ${item.main!.feelsLike}',
                          style: TextStyle(fontSize: 12)),
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
