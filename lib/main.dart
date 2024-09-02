import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather/pages/weather_home.dart';
import 'package:weather/weather_provider.dart';

import 'pages/setting_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();//if want to do anuthing before runApp
  SystemChrome.setPreferredOrientations([ //for Diseble rotation in app
    DeviceOrientation.portraitUp
  ]);
  runApp(ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,

        ),
        useMaterial3: true,
      ),
      initialRoute: WeatherHome.routeName,
      routes: {
        WeatherHome.routeName : (context) => WeatherHome(),
        SettingPage.routeName : (context) => SettingPage(),
      },
    );
  }
}


