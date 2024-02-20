import 'package:flutter/material.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use the default Firebase options
  );
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
        scaffoldBackgroundColor: const Color.fromRGBO(208, 249, 250, 1.0),
      ),
      home: const WelcomeScreen(),
    );
  }
}

