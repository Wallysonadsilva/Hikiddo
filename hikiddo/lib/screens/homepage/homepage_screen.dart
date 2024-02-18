import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/homepage/components/body.dart';
import 'package:hikiddo/components/bottom_navigation.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: const Body(),
      appBar: AppBar(
        backgroundColor: greenColor,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text('HIKIDDO!', style: TextStyle(
          color: Colors.white
          )
        ),
      ),
      drawer: const Drawer(
        backgroundColor:  Colors.white,
      ),
      bottomNavigationBar: const BottomNavigationBarComp(),
    );
  }
}
