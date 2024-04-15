import 'package:flutter/material.dart';
import 'package:hikiddo/components/text_field_container.dart';
import 'package:hikiddo/constants.dart';

class RoundPasswordField extends StatefulWidget {
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
  State<RoundPasswordField> createState() => RoundPasswordFieldState();
}

class RoundPasswordFieldState extends State<RoundPasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
        child: TextFormField(
      obscureText: obscureText,
      validator: widget.validator,
      onChanged: widget.onchanged,
      decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: widget.iconColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Change the icon dynamically based on whether text is obscured
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: widget.iconColor,
            ),
            onPressed: () {
              // Update the state upon button press to toggle text visibility
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
          border: InputBorder.none,
          errorMaxLines: 3),
    ));
  }
}
