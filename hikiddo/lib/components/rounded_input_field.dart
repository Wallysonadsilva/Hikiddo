import 'package:flutter/material.dart';
import 'package:hikiddo/components/text_field_container.dart';
import 'package:hikiddo/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final Color iconColor;
  final TextEditingController? controllers;

  const RoundedInputField({
    super.key,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged,
    this.iconColor = orangeColor,
    this.validator, this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controllers,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: iconColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
