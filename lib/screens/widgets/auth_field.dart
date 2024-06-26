import 'package:flutter/material.dart';
import 'package:kids_republik/utils/const.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.inputType,
    this.validators,
  }) : super(key: key);

  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final TextInputType inputType;
  final Function(String)? validators;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: labelText,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: kLabelStyle,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      validator: validators as String? Function(String?)?,
    );
  }
}
