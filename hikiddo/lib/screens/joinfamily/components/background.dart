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
            right: 0,
            child: Image.asset(
              "assets/images/joinFamily_top.png",
              width: size.width * 1.3,
              )
          ),
          Positioned(
            left: 0,
            bottom: 150,
            child: Image.asset(
              "assets/images/joinFamily_left.png",
              width: size.width * 1.1,
              )
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              "assets/images/joinFamily_bottom.png",
              width: size.width * 0.8,
              )
          ),
          child,
        ],
      ),
    );
  }
}