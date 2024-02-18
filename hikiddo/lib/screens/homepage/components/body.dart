import 'package:flutter/material.dart';
import 'package:hikiddo/screens/homepage/components/background.dart';
import 'package:hikiddo/components/dashboard_center_squares.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(
            "Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.0,
              fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ),
          Wrap(
            spacing: 8.0, // Space between the DashboardSquares
            alignment: WrapAlignment.center, // Center the squares within the Wrap
            children: const <Widget>[
              DashboardSquare(
                cardText: "Memory board",
                imagePath: "assets/images/joinFamily_bottom.png",
              ),
              DashboardSquare(
                cardText: "Voice Rec.",
                imagePath: "assets/images/joinFamily_bottom.png",
              ),
            ],
          ),
          Wrap(
            spacing: 8.0, // Space between the DashboardSquares
            alignment: WrapAlignment.center, // Center the squares within the Wrap
            children: const <Widget>[
              DashboardSquare(
                cardText: "Misson",
                imagePath: "assets/images/joinFamily_bottom.png",
              ),
              DashboardSquare(
                cardText: "Family Group",
                imagePath: "assets/images/joinFamily_bottom.png",
              ),
            ],
          ),
        ]
      ),
    );
  }
}
