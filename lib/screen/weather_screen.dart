import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _weatherStr = '';

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future getWeather() async {
    String key = '856822fd8e22db5e1ba48c0e7d69844a';
    String cityName = 'Seoul';
    WeatherFactory wf = WeatherFactory(key);
    Weather weather = await wf.currentWeatherByCityName(cityName);
    setState(() {
      _weatherStr = weather.toString();
    });
  }

  Widget _buildWidgetItem(BuildContext context) {
    if (_weatherStr.contains('Clear')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('서울', style: TextStyle(fontSize: 30)),
          Icon(Icons.wb_sunny, color: Colors.deepOrange, size: 150),
          Text('맑음', style: TextStyle(fontSize: 30)),
        ],
      );
    } else if (_weatherStr.contains('Cloud')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('서울', style: TextStyle(fontSize: 30)),
          Icon(Icons.cloud, color: Colors.deepOrange, size: 150),
          Text('흐림', style: TextStyle(fontSize: 30)),
        ],
      );
    } else if (_weatherStr.contains('Rain')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('서울', style: TextStyle(fontSize: 30)),
          Icon(Icons.grain, color: Colors.deepOrange, size: 150),
          Text('비', style: TextStyle(fontSize: 30)),
        ],
      );
    } else {
      return Center(
        child: Text('Can not find weather information x_x'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_weatherStr != '') {
      return Center(
        child: _buildWidgetItem(context),
      );
    } else {
      return Center(
        child: Text('Loading...'),
      );
    }
  }
}
