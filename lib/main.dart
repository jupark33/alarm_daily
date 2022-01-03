import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


void main() {
  runApp(const MyApp());
}

void _initNoiSetting() async {
  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  final initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );

  final initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await flutterLocalNotificationPlugin.initialize(
      initSettings,
  );

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  DateTime _dateTime = DateTime.now();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Body(),
    );
  }

  Widget Body() {
    return Container(
      padding: EdgeInsets.only(
        top: 100
      ),
      child: Column(
        children: <Widget>[
          hourMinute12H(),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 50
            ),
            child: new Text(
              _dateTime.hour.toString().padLeft(2, '0') + ':' +
                _dateTime.minute.toString().padLeft(2, '0'), //+ ':' +
                // _dateTime.second.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              ),
            )
          ),
          ElevatedButton(
              onPressed: () {
                _dailyAtTimeNotification(_dateTime);
              },
              child: Text('알람 설정'),
          )
        ],
      )
    );
  }

  Widget hourMinute12H() {
    return new TimePickerSpinner(
      is24HourMode: false,
      time: _dateTime,
      onTimeChange: (time) {
        setState(() {
          _dateTime = time;
        });

      }
    );
  }
}

// 출처 https://velog.io/@adbr/flutter-local-notification-Quick-Start2
Future _dailyAtTimeNotification(DateTime dateTime) async {
  final notiTitle = '알림';
  final notiDesc = '매일 알림 입니다.';
  final alarmId = 0;
  final chId = 'id';
  final chName = 'daily';

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final result = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
  ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );

  var android = AndroidNotificationDetails(chId, chName, importance: Importance.max, priority: Priority.max);
  var ios = IOSNotificationDetails();
  var detail = NotificationDetails(android: android, iOS: ios);

  print('_dailyAtTimeNotification, result : ${result}');

  if (result == true) {
    await flutterLocalNotificationsPlugin.
      resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(chId);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarmId,
        notiTitle,
        notiDesc,
        _setNotiTime(dateTime),
        detail,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: true
    );
  }

}

tz.TZDateTime _setNotiTime(DateTime dateTime) {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
      dateTime.hour, dateTime.minute
  );

  return scheduledDate;
}
