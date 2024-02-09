import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hikiddo',
      theme: ThemeData(
        primaryColor: primaryColorYellow,
        scaffoldBackgroundColor: const Color.fromRGBO(208, 249, 250, 1.0),
      ),
      home: const WelcomeScreen(),
    );
  }
}

