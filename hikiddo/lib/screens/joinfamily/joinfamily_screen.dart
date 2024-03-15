import 'package:flutter/material.dart';
import 'package:hikiddo/screens/joinfamily/components/body.dart';

class JoinFamilyScreen extends StatelessWidget {
  const JoinFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: Body(),
    );
  }
}