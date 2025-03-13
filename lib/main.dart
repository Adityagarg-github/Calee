import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';
import 'firebase_options.dart';
import 'package:alarm/alarm.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
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
  runApp(const App());
}


// Function to handle alarm triggers
void _onAlarmTrigger(AlarmSettings alarmSettings) {
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
  // You can show a dialog, push a screen, or trigger a notification
  showAlarmNotification(alarmSettings);
}

// Function to show a notification when alarm rings
void showAlarmNotification(AlarmSettings alarmSettings) {
  // You can use local_notifications package for actual notifications
  print("Reminder: ${alarmSettings.notificationTitle}");
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
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
