
import 'package:flutter/material.dart';
import 'package:hikiddo/components/already_have_an_account_check.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/components/rounded_password_field.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/loading.dart';
import 'package:hikiddo/screens/signup/components/background.dart';
import 'package:hikiddo/screens/signup/components/or_divider.dart';
import 'package:hikiddo/screens/signup/components/social_icons.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/login/login_screen.dart';
import 'package:hikiddo/services/auth.dart';


class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String name =  '';
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading ? const Loading() : Background(
      child: Form(
        key: _formKey,
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
              onChanged: (value) {
                setState(() => name = value);
              },
            ),
            RoundedInputField(
              validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              hintText: "Email",
              icon: Icons.mail,
              iconColor: redColor,
              onChanged: (value) {
                setState(() => email = value);
              },
            ),
            RoundPasswordField(
              iconColor: redColor,
              validator: (value) => value!.length < 6 ? 'Enter a password 6+ characters' : null,
              onchanged: (value) {
                setState(() => password = value);
              }
            ),
            SizedBox(height: size.height * 0.01),
            RoundButton(
              color: redColor,
              text: "SIGNUP",
              press: () async {
                if (_formKey.currentState!.validate()){
                  setState(() => loading = true);
                  dynamic result = await _auth.registerUser(context,email, password, name);
                  if(result != null){
                     // Navigate to the home screen
                    Navigator.pushReplacement(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const JoinFamilyScreen()),
                    );
                  }else {
                    setState(() => error = 'Please enter a valid Email');
                    setState(() => loading = false);
                  }
                }
              },
            ),
            Text(error),
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
      ),
    );
  }
}

