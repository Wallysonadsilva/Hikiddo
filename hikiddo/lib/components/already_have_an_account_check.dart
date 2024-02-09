import 'package:flutter/material.dart';

class AlreadyHaveAnAccountCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;
  final Color textcolor;
  const AlreadyHaveAnAccountCheck({
    super.key,
    this.login = true,
    required this.press, 
    this.textcolor =  const Color.fromRGBO(246, 163, 93, 1.0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          login ? "Don't have an Account ? " : "Already have an Account ?",
          style: const TextStyle(color: Colors.black),
        ),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Sign up here" : "Sign In",
            style: TextStyle(
              color: textcolor,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}

