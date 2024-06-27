import 'package:flutter/material.dart';

Widget customText(text, FontWeight fontWeight, double fontSize, Color color) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
  );
}
