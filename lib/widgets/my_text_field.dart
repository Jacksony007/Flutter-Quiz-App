import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextField extends StatelessWidget {
  final String label;
  final int maxLines;
  final int minLines;
  final Icon? icon;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool? enabled;

  MyTextField({
    required this.label,
    this.maxLines = 1,
    this.minLines = 1,
    this.icon,
    this.controller,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Colors.black87),
      minLines: minLines,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        suffixIcon: icon,
        labelText: label,
        labelStyle: TextStyle(color: Colors.black45),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }
}
