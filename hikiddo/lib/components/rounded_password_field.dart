import 'package:flutter/material.dart';
import 'package:hikiddo/components/text_field_container.dart';
import 'package:hikiddo/constants.dart';

class RoundPasswordField extends StatelessWidget {
  final ValueChanged<String> onchanged;
  final Color iconColor;
  final FormFieldValidator<String>? validator;
  const RoundPasswordField({
    super.key,
    required this.onchanged,
    this.iconColor = orangeColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        obscureText: true,
        validator: validator,
        onChanged: onchanged,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: iconColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: iconColor,
          ),
          border: InputBorder.none,
        ),
      )

    );
  }
}



