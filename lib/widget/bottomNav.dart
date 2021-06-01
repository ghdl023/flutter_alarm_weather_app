import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrange,
      child: Container(
        height: 70,
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.alarm, size: 30),
              child: Text('알람', style: TextStyle(fontSize: 10)),
            ),
            Tab(
              icon: Icon(Icons.wb_sunny, size: 30),
              child: Text('날씨', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}
