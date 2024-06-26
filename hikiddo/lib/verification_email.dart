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
                color: orangeColor,
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: SpinKitFadingCircle(
                color: greenColor,
                size: 50.0,
              ),
            ),
          ]
      ),
    );
  }
}
