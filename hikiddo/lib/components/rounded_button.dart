import 'package:flutter/material.dart';
import 'package:hikiddo/constants.dart';

class RoundButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color, textcolor;

  const RoundButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = orangeColor,
    this.textcolor = Colors.white,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              backgroundColor: color),
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(color: textcolor),
          )
        ),
      ),
    );
  }
}
