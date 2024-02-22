import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hikiddo/constants.dart';
import 'package:hikiddo/screens/login/components/background.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: Center(
        child: SpinKitFadingCircle(
          color: greenColor,
          size: 50.0,
        ),
      ),
    );
  }
}