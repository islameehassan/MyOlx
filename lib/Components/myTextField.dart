import 'package:flutter/material.dart';
import 'package:myolx/constants.dart';

class myTextField extends StatelessWidget {
  const myTextField({Key? key, required this.obscureText, required this.onChanged, required this.hintText, required this.icon, required this.controller}) : super(key: key);
  final bool obscureText;
  final Function onChanged;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return  TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
      textAlign: TextAlign.center,
      onChanged: (value) {
        onChanged(value);
      },
      decoration: kTextFieldDecoration.copyWith(
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}
