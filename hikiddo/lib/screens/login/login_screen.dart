import 'package:flutter/material.dart';
import 'package:hikiddo/screens/login/components/body.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: Body(),
    );
  }
}

