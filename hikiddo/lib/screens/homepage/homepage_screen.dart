import 'package:flutter/material.dart';
import 'package:hikiddo/screens/homepage/components/body.dart';
import 'package:hikiddo/components/bottom_navigation.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      body: Body(),
      bottomNavigationBar: BottomNavigationBarComp(),
    );
  }
}