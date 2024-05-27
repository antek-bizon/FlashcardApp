import 'package:flutter/material.dart';

class MultiLineTextField extends StatelessWidget {
  const MultiLineTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validatorText,
    this.enabled = true,
    this.onChanged,
    this.onSaved,
  });

  final TextEditingController controller;
  final String hintText;
  final String validatorText;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: 5,
      minLines: 1,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}
