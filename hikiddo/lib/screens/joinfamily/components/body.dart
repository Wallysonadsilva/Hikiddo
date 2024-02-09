import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/screens/homepage/homepage_screen.dart';
import 'package:hikiddo/screens/joinfamily/components/background.dart';


class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text("Join a family",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const Text(
            "group",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          RoundedInputField(
            icon: Icons.search,
            iconColor: Colors.grey,
            hintText: "Search or Create New",
            onChanged: (value) {},
          ),
          RoundButton(
            text: "Search",
            press: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context){
                      return const HomePageScreen();
                    }
                  ),
                );
            },
            color: const Color.fromRGBO(132, 189, 40, 1.0),
          ),
          SizedBox(height: size.height * 0.25,)
        ],
      ),
    );
  }
}

