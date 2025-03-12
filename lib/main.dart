import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/database/event.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

void requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    print("✅ Permission granted");
  } else {
    print("❌ Permission denied");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> setAlarmForEvent(Event event) async {
  tz.initializeTimeZones();

  // Get current UTC time (truncate milliseconds/microseconds)
  final nowUtc = DateTime.now().toUtc();
  final truncatedNowUtc = DateTime(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour, nowUtc.minute, nowUtc.second);

  // Convert event start time (IST) to UTC by subtracting 5:30 hours
  final eventStartIst = DateTime(
    truncatedNowUtc.year,
    truncatedNowUtc.month,
    truncatedNowUtc.day,
    event.stime.hour,
    event.stime.minute,
  );
  final eventStartUtc = eventStartIst.subtract(const Duration(hours: 5, minutes: 30));

  // Ensure timestamps have no floating precision errors
  final truncatedEventStartUtc = DateTime(
      eventStartUtc.year, eventStartUtc.month, eventStartUtc.day,
      eventStartUtc.hour, eventStartUtc.minute, eventStartUtc.second
  );

  // Ensure at least 60 seconds buffer
  final minFutureTime = truncatedNowUtc.add(const Duration(seconds: 60));

  await Future.sync(() => print("🔹 Current UTC Time: $truncatedNowUtc"));
  await Future.sync(() => print("🔹 Event Start UTC: $truncatedEventStartUtc"));
  await Future.sync(() => print("🔹 Min Future Time: $minFutureTime"));

  if (truncatedEventStartUtc.isBefore(minFutureTime)) {
    await Future.sync(() => print("❌ Skipping alarm for past event: ${event.title}"));
    return;
  }

  // Convert to TZDateTime in UTC
  final tzEventStartUtc = tz.TZDateTime.from(truncatedEventStartUtc, tz.getLocation('UTC'))
      .add(const Duration(hours: 5, minutes: 20)); // ✅ Added 5:20 hours 10 min early

  print("✅ Scheduling alarm for ${event.title} at $tzEventStartUtc");

  final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'alarm_channel',
    'Event Alarms',
    importance: Importance.high,
    priority: Priority.high,
  );

  final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    event.id ?? event.hashCode,
    'Reminder: ${event.title}',
    'Starts at ${event.displayTime()} at ${event.venue}',
    tzEventStartUtc,
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );

  print("✅ Alarm set successfully: ${event.title} at ${tzEventStartUtc.toUtc()} (UTC)");
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'calee-app',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  await EventDB.startInstance();

  bool signin = false;
  if (EventDB.firstRun() || FirebaseAuth.instance.currentUser == null) {
    signin = true;
  } else if (FirebaseAuth.instance.currentUser != null) {
    signin = true;
    await Ids.resolveUser();
  }

  RootPage.signin(signin);
  requestExactAlarmPermission();
  await initializeNotifications(); // Initialize notifications
  //await setHardcodedAlarm(); // Automatically set alarm on app start

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIT Ropar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      home: const RootPage(),
    );
  }
}
