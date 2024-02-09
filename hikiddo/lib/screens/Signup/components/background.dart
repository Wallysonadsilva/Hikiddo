import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/signUp_top.png",
              width: size.width * 2.5,
              )
          ),
          Positioned(
            right: 0,
            child: Image.asset(
              "assets/images/signUp_right.png",
              width: size.width * 1.0,
              )
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              "assets/images/signUp_bottom.png",
              width: size.width * 1.3,
              )
          ),
          child,
        ],
      ),
    );
  }
}