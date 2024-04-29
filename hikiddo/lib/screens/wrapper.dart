import 'package:flutter/material.dart';
import 'package:hikiddo/models/user.dart';
import 'package:hikiddo/screens/mainscreen/main_screen.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Return either Welcome page or Home Page base on user authetication
    final user = Provider.of<UserModel?>(context);
    if (user == null){
      return const WelcomeScreen();
    }else {
      return const MainScreen();
    }
  }
}