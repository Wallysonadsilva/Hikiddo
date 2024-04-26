import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hikiddo/components/already_have_an_account_check.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/components/rounded_password_field.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/signup/components/background.dart';
import 'package:hikiddo/screens/signup/components/or_divider.dart';
import 'package:hikiddo/screens/signup/components/social_icons.dart';
import 'package:hikiddo/screens/joinfamily/joinfamily_screen.dart';
import 'package:hikiddo/screens/login/login_screen.dart';
import 'package:hikiddo/services/auth.dart';
import 'package:hikiddo/verification_email.dart';

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
  String name = '';
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: loading
          ? const EmailVerifyPage()
          : Background(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "HIKIDDO!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: redColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    const Text(
                      "Create new",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Text(
                      "Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    RoundedInputField(
                      hintText: "Name",
                      iconColor: redColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a name";
                        }
                        // Notice the use of double quotes around the pattern and single quotes within it
                        if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
                          return "Names can only contain letters";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() => name = value);
                      },
                    ),
                    RoundedInputField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          // Update the error message state
                          return 'Enter an email';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          // Update for invalid email format
                          return 'Enter a valid email';
                        }
                        setState(() => error =
                            ''); // Clear any error message if all validations pass
                        return null;
                      },
                      hintText: "Email",
                      icon: Icons.mail,
                      iconColor: redColor,
                      onChanged: (value) {
                        setState(() => email = value);
                      },
                    ),
                    RoundPasswordField(
                      iconColor: redColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        } else if (!RegExp(r'^(?=.*[A-Z]).+$')
                            .hasMatch(value)) {
                          return 'Password must include at least  one uppercase letter';
                        } else if (!RegExp(r'^(?=.*\d).+$').hasMatch(value)) {
                          return 'Password must include at least one number';
                        }
                        return null;
                      },
                      onchanged: (value) {
                        setState(() => password = value);
                      },
                    ),
                    SizedBox(height: size.height * 0.01),
                    RoundButton(
                      color: redColor,
                      text: "SIGNUP",
                      press: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          User? user = await _auth.registerUser(
                              context, email, password, name);
                          if (user != null) {
                            // ignore: use_build_context_synchronously
                            await _auth.sendVerificationEmail(user, context);
                            Timer.periodic(const Duration(seconds: 5),
                                (timer) async {
                              if (await _auth.isEmailVerified(user)) {
                                timer.cancel();
                                setState(() => loading = false);
                                Navigator.pushReplacement(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const JoinFamilyScreen()),
                                );
                              }
                            });
                          } else {
                            setState(() {
                              loading = false;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(height: size.height * 0.02),
                    AlreadyHaveAnAccountCheck(
                      textcolor: redColor,
                      login: false,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
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
            ),
    );
  }
}
