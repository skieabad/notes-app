import 'package:flutter/material.dart';

Widget globalTextFields(TextEditingController? controller,
    String? Function(String?)? validator, String? hintText, Widget? suffixIcon,
    [bool obscureText = false, TextInputType? keyboardType]) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: keyboardType,
      validator: validator,
    ),
  );
}

