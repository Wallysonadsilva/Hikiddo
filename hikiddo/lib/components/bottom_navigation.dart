import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hikiddo/constants.dart';


class BottomNavigationBarComp extends StatelessWidget {

  final int currentIndex; // Current index
  final Function(int) onTap; // Callback function

  const BottomNavigationBarComp({

    super.key,
    required this.currentIndex,
    required this.onTap,

  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: lightBlueColor,
      index: currentIndex,
      onTap: onTap,
      color: const Color.fromRGBO(123, 189, 40, 0.9),
      animationDuration: const Duration(milliseconds: 400),
      items: const <Widget> [
        Icon(Icons.person, color: Colors.white),
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.location_pin, color:  Colors.white),
      ],
    );
  }
}
