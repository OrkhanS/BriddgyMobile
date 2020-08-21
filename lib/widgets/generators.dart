import 'dart:ui';

import 'package:flutter/material.dart';

Color colorFor(String text) {
  var hash = 0;
  for (var i = 0; i < text.length; i++) {
    hash = text.codeUnitAt(i) + ((hash << 5) - hash);
  }
  final finalHash = hash.abs() % (256 * 256 * 256);
  final red = ((finalHash & 0xFF0000) >> 16);
  final blue = ((finalHash & 0xFF00) >> 8);
  final green = ((finalHash & 0xFF));
  final color = Color.fromRGBO(red, green, blue, 1);
  return color;
}

class InitialsAvatarWidget extends StatelessWidget {
  final String firstName, lastName;
  final double size;
  InitialsAvatarWidget(this.firstName, this.lastName, this.size);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorFor(firstName.toString()),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          firstName.toString()[0].toUpperCase() + lastName.toString()[0].toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
