import 'package:flutter/material.dart';
import 'package:hikiddo/components/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final Color iconColor;
  const RoundedInputField({
    super.key,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged, 
    this.iconColor = const Color.fromRGBO(246, 163, 93, 1.0),
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
     child: TextField(
      onChanged: onChanged,
       decoration: InputDecoration(
         icon: Icon(
           icon,
           color:  iconColor,
         ),
         hintText: hintText,
         border: InputBorder.none,
       ),
     ),
    );
  }
}