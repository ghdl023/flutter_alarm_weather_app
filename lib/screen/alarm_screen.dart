import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:intl/intl.dart';

import 'package:flutter_weather_app/model/alarm_model.dart';

class AlarmScreen extends StatefulWidget {
  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final List<AlarmInfo> alarmList = <AlarmInfo>[];
  bool _isAlarmOn = false;
  int _alarmID = 0;
  int _listIndex = 0;

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

  FloatingActionButton alarmAddButton() {
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

                setAlarmManager();
                addItemToList();
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

  void addItemToList() {
    setState(() {
      _isAlarmOn = true;
      // saveAlarmInfo(_listIndex, _date, _time.format(context), _isAlarmOn);
      alarmList.insert(_listIndex, AlarmInfo(_date, _time, _isAlarmOn));
      _listIndex++;
      // saveAlarmCount(_listIndex);
    });
  }

  ListView alarmPage() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alarmList.length,
      itemBuilder: (BuildContext context, int index) {
        if (alarmList.isEmpty) {
          return Text('Alarm is empty!');
        }
        return AlarmTile(alarmList, index);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: alarmAddButton(),
      body: Container(
        child: alarmPage(),
      ),
    );
  }
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

class AlarmTile extends StatefulWidget {
  final List<AlarmInfo> _alarmInfo;
  final int _index;

  AlarmTile(this._alarmInfo, this._index);

  @override
  _AlarmTileState createState() => _AlarmTileState();
}

class _AlarmTileState extends State<AlarmTile> {
  bool _isChecked;

  @override
  Widget build(BuildContext context) {
    if (widget._alarmInfo.isEmpty) {
      return ListTile(
        title: Text('등록된 알람이 없습니다'),
        subtitle: Text('알람을 등록해주세요.'),
      );
    }

    _isChecked = widget._alarmInfo[widget._index].isAlarmOn();
    final f = new DateFormat('yyyy-MM-dd H:mm');
    int counterForAlarmOn = 0;
    return ListTile(
      leading: Icon(
        Icons.alarm,
        size: 40,
      ),
      title:
          Text('${f.format(widget._alarmInfo[widget._index].getAlarmDate())}'),
      subtitle: Text('알람'),
      trailing: Switch(
        value: _isChecked,
        onChanged: (value) async {
          setState(() {
            _isChecked = value;
          });

          widget._alarmInfo[widget._index]
              .setAlarmOn(!widget._alarmInfo[widget._index].isAlarmOn());
          // var alarmID = await getAlarmID(widget._index);
          var alarmID = widget._index;
          if (widget._alarmInfo[widget._index].isAlarmOn()) {
            AndroidAlarmManager.oneShotAt(
              widget._alarmInfo[widget._index].getAlarmDate(),
              alarmID,
              startAlarm,
              exact: true,
            );
          } else {
            AndroidAlarmManager.cancel(alarmID);
            stopAlarm();
          }

          for (int i = 0; i < widget._alarmInfo.length; i++) {
            if (widget._alarmInfo[i].isAlarmOn() == true) {
              counterForAlarmOn++;
            }
          }

          if (counterForAlarmOn == 0) {
            ForegroundService.stopForegroundService();
          } else {
            startService(widget._alarmInfo[widget._index].getAlarmDate());
            counterForAlarmOn = 0;
          }

          // saveAlarmInfo(
          //   widget._index,
          //   widget._alarmInfo[widget._index].getAlarmDate(),
          //   (widget._alarmInfo[widget._index].getAlarmTime()).format(context),
          //   widget._alarmInfo[widget._index].isAlarmOn();
          // );
        },
      ),
      onLongPress: () async {
        // await showAlertDialog(context, widget._alarmInfo, widget._index);
        // Phoenix.rebirth(context);
      },
    );
  }
}
