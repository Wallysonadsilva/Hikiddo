import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNavigationBarComp extends StatelessWidget {

  const BottomNavigationBarComp({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: const Color.fromRGBO(208, 249, 250, 1.0),
      color: const Color.fromRGBO(123, 189, 40, 0.9),
      animationDuration: const Duration(milliseconds: 400),
      items: const [
        Icon(Icons.person, color: Colors.white),
        Icon(Icons.home, color: Colors.white),
        Icon(Icons.location_pin, color:  Colors.white),
      ],
    );
  }
}
