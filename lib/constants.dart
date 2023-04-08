import 'package:flutter/material.dart';


const Color kBackgroundColor = Color(0xFF161616);
const Color kTextColor = Color(0xFFCCFE47);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
  ),
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    bottom: BorderSide(color: Colors.pinkAccent, width: 2.0),
  ),
);