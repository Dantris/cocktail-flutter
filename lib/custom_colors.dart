import "package:flutter/material.dart";

class CustomColors {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF444444);
  static const Color whiteish = Color(0xFFEAEAEA);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFA500), // Darker Gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
