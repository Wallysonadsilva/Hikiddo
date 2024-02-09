import 'package:flutter/material.dart';
import 'package:hikiddo/components/already_have_an_account_check.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/components/rounded_password_field.dart';
import 'package:hikiddo/screens/Signup/components/background.dart';
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
              color: Color.fromRGBO(255, 87, 87, 1.0),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          const Text("Create new",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const Text("Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          AlreadyHaveAnAccountCheck(
            textcolor: const Color.fromRGBO(255, 87, 87, 1.0),
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
          SizedBox(height: size.height * 0.02),
          RoundedInputField(
            hintText: "Name",
            iconColor: const Color.fromRGBO(255, 87, 87, 1.0),
            onChanged: (value) {},
          ),
          RoundedInputField(
            hintText: "Email",
            icon: Icons.mail,
            iconColor: const Color.fromRGBO(255, 87, 87, 1.0),
            onChanged: (value) {},
          ),
          RoundPasswordField(
            iconColor: const Color.fromRGBO(255, 87, 87, 1.0),
            onchanged: (value) {}
          ),
          SizedBox(height: size.height * 0.02),
          RoundButton(
            color: const Color.fromRGBO(255, 87, 87, 1.0),
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
          )
        ],
      ),
    );
  }
}

