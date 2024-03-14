import 'package:flutter/material.dart';
import 'package:hikiddo/components/top_navigation.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/profile_22/components/body.dart';
import 'package:hikiddo/components/bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavigationBar(),
      body: Body(),
      //bottomNavigationBar: const BottomNavigationBarComp(innerColor: lightBlueColor,),
      drawer: const Drawer(
        backgroundColor: Colors.white,
      )
    );
  }
}
