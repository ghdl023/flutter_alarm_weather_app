// import 'package:flutter/material.dart';

// import 'package:android_alarm_manager/android_alarm_manager.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:foreground_service/foreground_service.dart';

// import 'package:flutter_weather_app/screen/alarm_screen.dart';
// import 'package:flutter_weather_app/model/alarm_model.dart';

// class AlarmTile extends StatefulWidget {
//   final List<AlarmInfo> _alarmInfo;
//   final int _index;

//   AlarmTile(this._alarmInfo, this._index);

//   @override
//   _AlarmTileState createState() => _AlarmTileState();
// }

// class _AlarmTileState extends State<AlarmTile> {
//   bool _isChecked;

//   @override
//   Widget build(BuildContext context) {
//     if(widget._alarmInfo.isEmpty) {
//       return ListTile(
//         title: Text('등록된 알람이 없습니다'),
//         subtitle: Text('알람을 등록해주세요.'),
//       )
//     }

//     _isChecked = widget._alarmInfo[widget._index].isAlarmOn();
//     final f = new DateFormat('yyyy-MM-dd H:mm');
//     int counterForAlarmOn = 0;
//     return ListTile(
//       leading: Icon(
//         Icons.alarm,
//         size:40,
//       ),
//       title: Text('${f.format(widget._alarmInfo[widget._index].getAlarmDate())}'),
//       subtitle: Text('알람'),
//       trailing: Switch(
//         value: _isChecked,
//         onChanged: (value) async {
//           setState(() {
//                      _isChecked = value; 
//                     });

//                     widget._alarmInfo[widget._index].setAlarmOn(!widget._alarmInfo[widget._index].isAlarmOn());
//                     // var alarmID = await getAlarmID(widget._index);
//                     var alarmID = widget._index;
//                     if(widget._alarmInfo[widget._index].isAlarmOn()) {
//                       AndroidAlarmManager.oneShotAt(
//                         widget._alarmInfo[widget._index].getAlarmDate(),
//                         alarmID,
//                         startAlarm,
//                         exact: true,
//                       );
//                     } else {
//                       AndroidAlarmManager.cancel(alarmID);
//                       stopAlarm();
//                     }

//                     for(int i=0; i<widget._alarmInfo.length; i++) {
//                       if(widget._alarmInfo[i].isAlarmOn() == true) {
//                         counterForAlarmOn++;
//                       }
//                     }

//                     if(counterForAlarmOn == 0) {
//                       ForegroundService.stopForegroundService();
//                     } else {
//                       startService(widget._alarmInfo[widget._index].getAlarmDate());
//                       counterForAlarmOn = 0;
//                     }

//                     // saveAlarmInfo(
//                     //   widget._index,
//                     //   widget._alarmInfo[widget._index].getAlarmDate(),
//                     //   (widget._alarmInfo[widget._index].getAlarmTime()).format(context),
//                     //   widget._alarmInfo[widget._index].isAlarmOn();
//                     // );
//         },
//       ),
//       onLongPress: () async {
//         // await showAlertDialog(context, widget._alarmInfo, widget._index);
//         // Phoenix.rebirth(context);
//       },
//     )
//   }
// }
