import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/signup/signup_screen.dart';
import 'package:hikiddo/screens/login/login_screen.dart';
import 'package:hikiddo/screens/welcome/components/background.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // this size provide us a total height and width of the screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.08),
            const Text(
              "HIKIDDO!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: orangeColor
                ),
            ),
            SizedBox(height: size.height * 0.02),
            Positioned(
              child: Image.asset(
                "assets/images/startPage_center.png",
                width: size.width * 0.8,
              ),
            ),
            //SvgPicture.asset(
              //"assets/icons/chat.svg",
              //height: size.height * 0.4,
            //),
            SizedBox(height: size.height * 0.04),
            RoundButton(
              text: "LOGIN",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context){
                      return const LoginScreen();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            RoundButton(
              text: "SIGN UP",
              //textcolor: const Color.fromRGBO(4, 125, 120, 0.7),
              color: const Color.fromRGBO(186, 87, 37, 0.7),
              press: () {
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context){
                      return const SignUpScreen();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

