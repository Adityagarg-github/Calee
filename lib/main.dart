import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iitropar/database/local_db.dart';
import 'firebase_options.dart';
import 'package:alarm/alarm.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:iitropar/views/PBTabView.dart';
import 'package:iitropar/views/signin.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

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

  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    user = await FirebaseAuth.instance.authStateChanges().first;
  }

  bool signin = (EventDB.firstRun() || user == null);
  if (!signin) {
    await Ids.resolveUser();
  }

  RootPage.signin(signin);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(App(savedThemeMode: savedThemeMode));
}

// Function to handle alarm triggers
void _onAlarmTrigger(AlarmSettings alarmSettings) {
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
  showAlarmNotification(alarmSettings);
}

// Function to show a notification when alarm rings
void showAlarmNotification(AlarmSettings alarmSettings) {
  print("Reminder: ${alarmSettings.notificationTitle}");
  print("Alarm Triggered at: ${alarmSettings.dateTime}");
}

class App extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const App({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: _lightTheme,  // ✅ Updated Light Theme
      dark: _darkTheme,    // ✅ Updated Dark Theme
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'IIT Ropar App',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: '/',
        home: const RootPage(),
      ),
    );
  }
}

// Light Theme
final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.amber, // Elegant gold tone
  scaffoldBackgroundColor: Color(0xFFFAF3E0), // Soft warm beige
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.light(
    primary: Color(0xFFD4A373), // Warm gold-brown
    secondary: Color(0xFFA67C52), // Rich coffee brown
    background: Color(0xFFFAF3E0), // Light creamy beige
    surface: Colors.white, // Cards and modals

    onPrimary: Colors.white, // White text/icons on primary
    onSecondary: Colors.white, // White text/icons on secondary
    onBackground: Color(0xFF3E2723), // Deep brown for contrast
    onSurface: Colors.black87, // Dark text/icons on surfaces
    error: Color(0xFFB71C1C), // Deep crimson for errors
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFD4A373), // Warm gold AppBar
    foregroundColor: Colors.white, // White text/icons
    elevation: 3,
  ),
  cardColor: Colors.white, // Clean white cards
  shadowColor: Colors.brown.withOpacity(0.2), // Subtle warm shadows
);



// Dark Theme
final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF0A0A0A), // True black background
  primarySwatch: Colors.cyan, // Cool neon cyan accents
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF00ADB5), // Electric cyan highlights
    secondary: Color(0xFF222831), // Dark graphite gray
    background: Color(0xFF0A0A0A), // True black background
    surface: Color(0xFF161616), // Almost black for cards & modals

    onPrimary: Colors.black, // Text/icons on primary
    onSecondary: Colors.white, // Text/icons on secondary
    onBackground: Colors.white, // Bright white text for contrast
    onSurface: Colors.white70, // Slightly dimmed white for surfaces
    error: Color(0xFFCF6679), // Vibrant pinkish-red for errors
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF161616), // Deep black AppBar
    foregroundColor: Colors.white, // White text/icons
    elevation: 2,
  ),
  cardColor: Color(0xFF161616), // Dark mode cards
  shadowColor: Colors.black.withOpacity(0.6), // Darker shadows for depth
);



