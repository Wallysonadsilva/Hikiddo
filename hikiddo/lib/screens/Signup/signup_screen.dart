import 'package:flutter/material.dart';
import 'package:hikiddo/screens/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Body(),
      ),
    );
  }
}

