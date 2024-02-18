import 'package:flutter/material.dart';

class DashboardSquare extends StatelessWidget {
  final String cardText;
  final String imagePath;
  const DashboardSquare({
    super.key,
    required this.cardText,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: 160.0, // Consider adjusting the width based on your layout needs
        height: 160.0,
        child: Card(
          color: const Color.fromRGBO(123, 189, 40, 0.9),
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(imagePath, width: 90.0),
                  const SizedBox(height: 10.0),
                  Text(
                    cardText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
