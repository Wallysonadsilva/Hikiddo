
import 'package:flutter/material.dart';
import 'package:hikiddo/components/already_have_an_account_check.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/components/rounded_password_field.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/Signup/components/background.dart';
import 'package:hikiddo/screens/Signup/components/or_divider.dart';
import 'package:hikiddo/screens/Signup/components/social_icons.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/login/login_screen.dart';


class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text("HIKIDDO!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 36,
              color: redColor,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          const Text("Create new",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const Text("Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          RoundedInputField(
            hintText: "Name",
            iconColor: redColor,
            onChanged: (value) {},
          ),
          RoundedInputField(
            hintText: "Email",
            icon: Icons.mail,
            iconColor: redColor,
            onChanged: (value) {},
          ),
          RoundPasswordField(
            iconColor: redColor,
            onchanged: (value) {}
          ),
          SizedBox(height: size.height * 0.01),
          RoundButton(
            color: redColor,
            text: "SIGNUP",
            press: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context){
                      return const JoinFamilyScreen();
                    }
                  ),
              );
            },
          ),
          SizedBox(height: size.height * 0.02),
          AlreadyHaveAnAccountCheck(
            textcolor: redColor,
            login:false,
            press: () {
              Navigator.push(
                context, MaterialPageRoute(
                  builder: (context){
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
          const OrDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SocialIcon(
                iconSrc: "assets/icons/facebook.svg",
                press: () {},
              ),
              SocialIcon(
                iconSrc: "assets/icons/google-plus.svg",
                press: () {},
              ),
              SocialIcon(
                iconSrc: "assets/icons/apple-logo.svg",
                press: () {},
              )
            ],
          ),
          SizedBox(height: size.height * 0.09),
        ],
      ),
    );
  }
}

