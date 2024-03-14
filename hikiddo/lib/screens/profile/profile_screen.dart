import 'package:flutter/material.dart';
import 'package:hikiddo/screens/profile/components/body.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: TopNavigationBar(),
      body:  Body(),
    );
  }
}