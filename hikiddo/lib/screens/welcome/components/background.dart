import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

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
              "assets/images/startpage_top.png",
              width: size.width * 0.7,
            ),
          ),
          Positioned(
            left: 0,
            child: Image.asset(
              "assets/images/startPage_left.png",
              width: size.width * 0.8,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/images/startPage_bottom.png",
              width: size.width * 0.8,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
