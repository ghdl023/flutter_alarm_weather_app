import 'package:flutter/material.dart';
import 'package:flutter_weather_app/screen/weather_screen.dart';
import 'package:flutter_weather_app/widget/bottomNav.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알람 및 날씨',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(),
              WeatherScreen(),
            ],
          ),
          bottomNavigationBar: BottomNav(),
        ),
      ),
    );
  }
}
