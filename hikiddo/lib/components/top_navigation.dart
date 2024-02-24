import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/welcome/welcome_screen.dart';
import 'package:hikiddo/services/auth.dart';

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  TopNavigationBar({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return  AppBar(
        backgroundColor: greenColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('HIKIDDO!', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const WelcomeScreen()),
              );
            },
          )
        ],
      );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
