import 'package:flutter/material.dart';
import 'package:kids_republik/utils/const.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    this.enabled,
    required this.labelText,
    required this.controller,
    required this.inputType,
    this.validators,
    this.onChanged,
    this.maxLines = 1, // Add maxLines property with a default value of 1
  }) : super(key: key);

  final bool? enabled;
  final String labelText;
  final TextEditingController controller;
  final TextInputType inputType;
  final Function(String)? validators;
  final ValueChanged<String>? onChanged;
  final int maxLines; // New property for maxLines

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          enabled: enabled ?? true,
          controller: controller,
          keyboardType: inputType,
          onChanged: onChanged,
          maxLines: maxLines, // Set maxLines property
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.65),
            fontSize: 14.0,
          ),
          decoration: InputDecoration(
            isDense: true,
            labelText: labelText,
            labelStyle: kLabelStyle.copyWith(
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.25),
            ),
            hintStyle: kLabelStyle.copyWith(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.3),
            ),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[400]!, width: 0.8),
            ),
          ),
          validator: validators as String? Function(String?)?,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.007,)
      ],
    );
  }
}
