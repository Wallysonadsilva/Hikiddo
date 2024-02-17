import 'package:flutter/material.dart';
import 'package:hikiddo/screens/homepage_test/components/body.dart';
import 'package:hikiddo/components/bottom_navigation.dart';

class HomePageScreen2 extends StatelessWidget {
  const HomePageScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      bottomNavigationBar: BottomNavigationBarComp(),
    );
  }
}
