import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/loading.dart';
import 'package:hikiddo/screens/signup/signup_screen.dart';
import 'package:hikiddo/screens/forgot_password/forgot_pw_page.dart';
import 'package:hikiddo/screens/login/components/background.dart';
import 'package:hikiddo/screens/mainscreen/main_screen.dart';
import 'package:hikiddo/services/auth.dart';
import '../../../components/already_have_an_account_check.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // Text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: loading
            ? const Loading()
            : Background(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: size.height * 0.0),
                        Image.asset(
                          "assets/images/login_center.png",
                          width: size.width * 0.6,
                        ),
                        const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        RoundedInputField(
                          validator: (value) =>
                              value!.isEmpty ? 'Enter an email' : null,
                          hintText: "Your Email",
                          onChanged: (value) {
                            setState(() => email = value);
                          },
                        ),
                        RoundPasswordField(
                          validator: (value) => value!.length < 6
                              ? 'Enter a password 6+ characters'
                              : null,
                          onchanged: (value) {
                            setState(() => password = value);
                          },
                        ),
                        GestureDetector(
                            onTap: () {
                              // navigate to new page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              "Forgot your Password?",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue),
                            )),
                        const SizedBox(height: 20),
                        RoundButton(
                          text: "LOGIN",
                          press: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => loading = true);
                              dynamic result = await _auth.userSignIn(
                                  context, email, password);
                              if (result != null) {
                                // Navigate to the home screen
                                Navigator.pushReplacement(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainScreen()),
                                );
                              } else {
                                setState(() => error = 'Could not sign in with those credentials');
                                setState(() => loading = false);
                              }
                            }
                          },
                          color: orangeColor,
                          textcolor: Colors.white,
                        ),
                        Text(error),
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
                  ),
                ),
              ),
      ),
    );
  }
}
