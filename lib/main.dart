import 'package:flutter/material.dart';
import 'package:yarn_tracker/screens/welcome_screen.dart';

void main() {
  runApp(YarnTrackerApp());
}

class YarnTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yarn Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 6,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          )
        )
        ),
      home: WelcomeScreen(),
    );
  }
}

