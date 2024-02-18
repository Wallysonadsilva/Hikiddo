import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/screens/Signup/signup_screen.dart';
import 'package:hikiddo/screens/homepage/homepage_screen.dart';
import 'package:hikiddo/screens/login/components/background.dart';
import '../../../components/already_have_an_account_check.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Positioned(
            child: Image.asset(
              "assets/images/login_center.png",
              width: size.width * 0.6,
            ),
          ),
          //SvgPicture.asset(
          //"assets/icons/",
          //height: size.height * 0.3,
          //),
          const Text(
            "LOGIN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          RoundedInputField(
            hintText: "Your Email",
            onChanged: (value) {},
          ),
          RoundPasswordField(
            onchanged: (value) {},
          ),
          const Text("Forgot your Password?"),
          RoundButton(
            text: "LOGIN",
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const HomePageScreen();
                }),
              );
            },
            color: const Color.fromRGBO(246, 163, 93, 0.7),
            textcolor: Colors.white,
          ),
          AlreadyHaveAnAccountCheck(press: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return const SignUpScreen();
              }),
            );
          })
        ],
      ),
    );
  }
}
