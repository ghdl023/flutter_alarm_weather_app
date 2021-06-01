import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  bool _isAlarmOn = false;
  int _alarmID = 0;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  Future<DateTime> selectDate(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2999));
  }

  Future<TimeOfDay> selectTime(BuildContext context) {
    return showTimePicker(context: context, initialTime: TimeOfDay.now());
  }

  Widget addAlarm() {
    return FloatingActionButton(
      tooltip: '알람 추가',
      child: Icon(Icons.alarm_add),
      onPressed: () {
        selectDate(context).then((value) {
          _date = value;
          if (_date != null) {
            selectTime(context).then((value) {
              _time = value;
              if (_time != null) {
                _date = DateTime(_date.year, _date.month, _date.day, _time.hour,
                    _time.minute);

                // setAlarmManager();
                // addItemToList();
              } else {
                _time = TimeOfDay.now();
              }
            });
          } else {
            _date = DateTime.now();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void setAlarmManager() async {
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.oneShotAt(
      _date,
      _alarmID,
      startAlarm,
      exact: true,
    );

    // await saveAlarmID(_listIndex - 1, _alarmID);
    _alarmID++;
    startService(_date);
  }

  void startService(DateTime dateTime) async {
    if (!(await ForegroundService.foregroundServiceIsStarted())) {
      await ForegroundService.setServiceIntervalSeconds(10);

      await ForegroundService.notification.startEditMode();
      await ForegroundService.notification.setTitle('등록된 알람!');
      await ForegroundService.notification.setText('$dateTime');
      await ForegroundService.notification.finishEditMode();

      await ForegroundService.startForegroundService(foregroundServiceFunction);
      await ForegroundService.getWakeLock();
    }

    await ForegroundService.setupIsolateCommunication(
        (data) => {debugPrint('main received: $data')});
  }

  void foregroundServiceFunction() {
    debugPrint('The current time is: ${DateTime.now()}');

    if (!ForegroundService.isIsolateCommunicationSetup) {
      ForegroundService.setupIsolateCommunication(
          (data) => {debugPrint('bg isolate received: $data')});
    }

    ForegroundService.sendToPort('message from bg isolate');
  }
}

void startAlarm() async {
  print('start alarm!');
  AudioCache player = AudioCache();
  AudioPlayer audioPlayer = await player.loop('good_morning.mp3');

  ReceivePort recvPort = new ReceivePort();
  IsolateNameServer.registerPortWithName(recvPort.sendPort, 'player');
  recvPort.listen((message) {
    if (audioPlayer != null) {
      audioPlayer.stop();
    }

    recvPort.close();
    IsolateNameServer.removePortNameMapping('player');
  });

  // SendPort sendPort = IsolateNameServer.lookupPortByName('rebirth');
  // sendPort.send('start');
}

void stopAlarm() {
  SendPort sendPort = IsolateNameServer.lookupPortByName('player');
  if (sendPort != null) {
    sendPort.send('stop');
  }
}
