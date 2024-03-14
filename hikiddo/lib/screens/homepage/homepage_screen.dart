import 'package:flutter/material.dart';
import 'package:hikiddo/screens/homepage/components/body.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  @override
  HomePageScreenState createState() => HomePageScreenState();
}

class HomePageScreenState extends State<HomePageScreen> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}
