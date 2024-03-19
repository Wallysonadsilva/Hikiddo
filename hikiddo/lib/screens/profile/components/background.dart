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
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "assets/images/homePage_top_right.png",
              width: size.width * 1.3,
              )
          ),
          Positioned(
            left: 0,
            top: 300.0,
            child: Image.asset(
              "assets/images/homePage_left.png",
              width: size.width * 0.8,
              )
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              "assets/images/homePage_bottom_right.png",
              width: size.width * 1.0,
              )
          ),
          child,
        ],
      ),
    );
  }
}