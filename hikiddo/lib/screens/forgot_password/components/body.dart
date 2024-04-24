import 'package:flutter/material.dart';
import 'package:hikiddo/components/rounded_button.dart';
import 'package:hikiddo/components/rounded_input_field.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/forgot_password/components/background.dart';
import 'package:hikiddo/screens/login/login_screen.dart';
import 'package:hikiddo/services/auth.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: greenColor,
          title: const Text('HIKIDDO!', style: TextStyle(color: Colors.white)),
        ),
        body: Background(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size
                  .height, // Ensures the column expands to at least the height of the screen
            ),
            child: IntrinsicHeight(
              // This ensures the column doesn't stretch beyond its intrinsic height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "RESET PASSWORD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: greenColor,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  RoundedInputField(
                    icon: Icons.mail,
                    iconColor: Colors.grey,
                    hintText: "          Enter email",
                    controllers: _emailController,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: size.height * 0.01),
                  RoundButton(
                    text: "send",
                    color: greenColor,
                    press: sentResetLink,
                  ),
                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

void sentResetLink() async {
  final email = _emailController.text.trim();
  if (email.isEmpty) {
    showAlertDialog("Email is required");
  } else {
    await _authService.sendPasswordResetEmail(email, (String message) async {
      if (mounted) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text("Password Reset"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        // Perform navigation after the dialog is dismissed
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }
}


  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Password Reset"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
