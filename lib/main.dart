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
  scaffoldBackgroundColor: Color(0xFFF2F2F2), // Soft neutral gray
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.light(
    primary: Color(0xFF666666), // Neutral dark gray for contrast
    secondary: Color(0xFFD1D1D1), // Muted secondary elements
    background: Color(0xFFF2F2F2), // Light gray background
    surface: Colors.white, // Cards and modals

    onPrimary: Colors.white, // Text/icons on primary elements
    onSecondary: Colors.black87, // Dark text/icons on secondary elements
    onBackground: Colors.black87, // Darker text for readability
    onSurface: Colors.black, // Strong contrast for UI elements
    error: Color(0xFFD64550), // Professional red for errors
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Keeps navbar color visible
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black87), // Ensures icon visibility
  ),
  cardColor: Colors.white, // Clean white cards
  shadowColor: Colors.grey.withOpacity(0.2), // Subtle shadows
);



// Dark Theme
final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF121212), // Dark charcoal gray
  fontFamily: 'Montserrat',
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFBBBBBB), // Soft off-white for better contrast
    secondary: Color(0xFF242424), // Dark secondary elements
    background: Color(0xFF121212), // True dark gray
    surface: Color(0xFF1E1E1E), // Slightly lighter gray for cards

    onPrimary: Colors.black, // Dark text/icons on light primary elements
    onSecondary: Colors.white, // White text/icons for contrast
    onBackground: Colors.white, // White text for readability
    onSurface: Colors.white70, // Soft white for smooth UI
    error: Color(0xFFFF5252), // Vibrant red for errors
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent, // Keeps navbar color visible
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white), // Ensures icon visibility
  ),
  cardColor: Color(0xFF1E1E1E), // Dark but not black cards
  shadowColor: Colors.black.withOpacity(0.3), // Deeper shadow effects
);




