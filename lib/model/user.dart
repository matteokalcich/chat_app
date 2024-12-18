import 'package:flutter/material.dart' show Color;

class User {
  final String username, lastmsg, iconSrc;
  final Color color;

  User({
    required this.username,
    this.lastmsg = 'Build and animate an iOS app from scratch',
    this.iconSrc = "assets/icons/ios.svg",
    this.color = const Color(0xFF7553F6),
  });

}
