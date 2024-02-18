import 'package:flutter/material.dart';
import '../../../constants.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      width: size.width * 0.8,
      child: Row(
        children: <Widget>[
          dividerBuild(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "OR",style: TextStyle(
                color: redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          dividerBuild()
        ],
      ),
    );
  }

  Expanded dividerBuild() {
    return const Expanded(
          child: Divider(
            color: Color(0xFFD9D9D9),
            height: 1.5,
            ),
        );
  }
}