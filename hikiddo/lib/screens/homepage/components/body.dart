import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/screens/homepage/components/background.dart';


class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 330,
              height: 65,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(132, 189, 40, 1.0),
                borderRadius: BorderRadius.circular(15.0), // Adjust the value as needed
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10.0),
                    const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 40,
                    ), // Adjust the icon color
                    const SizedBox(width: 10.0), // Add some space between the icon and text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "John Alves",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ), // Adjust the text color
                        ),
                        Text(
                          "Family - The Alves Family",
                          style: TextStyle(
                            color: Colors.white
                          ), // Adjust the text color
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          SizedBox(height: size.height * 0.05),
          Align(alignment: Alignment.centerLeft,
            child: RoundButton(
              text: "Memory Board",
              press: () {},
              textcolor: Colors.black,
              color: Colors.white,
            ),
          ),
          Align(alignment: Alignment.centerRight,
            child: RoundButton(
              text: "Challenges",
              press: () {},
              textcolor: Colors.black,
              color: Colors.white,
            ),
          ),
          Align(alignment: Alignment.centerLeft,
            child: RoundButton(
              text: "Record a voice memo",
              press: () {},
              textcolor: Colors.black,
              color: Colors.white,
            ),
          ),
          Align(alignment: Alignment.centerRight,
            child: RoundButton(
              text: "Family settings",
              press: () {},
              textcolor: Colors.black,
              color: Colors.white,
            ),
          ),
          SizedBox(height: size.height * 0.2),
        ],
      ),
    );
  }
}

