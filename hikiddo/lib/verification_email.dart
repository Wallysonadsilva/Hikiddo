import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/login/components/background.dart';

class EmailVerifyPage extends StatelessWidget {
  const EmailVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Verification email has been sent to your email. Please verify to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: orangeColor, // Sets the color of the text
                fontSize: 16, // Sets the size of the font
                fontStyle: FontStyle.italic, // Adds italics
                fontWeight: FontWeight.bold, // Makes the font bold
              ),
            ),
            SizedBox(height: 20.0,),
            Center(
              child: SpinKitFadingCircle(
                color: greenColor,
                size: 50.0,
              ),
            ),
          ]),
    );
  }
}
