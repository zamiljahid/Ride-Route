import 'package:flutter/material.dart';

class CustomColors {
  // Solid Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color royalBlue = Color(0xFF4169E1); // Royal Blue
  static const Color navyBlue = Color(0xFF000080); // Navy Blue
  static const Color customeBlue = Color(0xFF010159); // Navy Blue

  static const LinearGradient golden = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD700), // Classic Gold
      Color(0xFFFFE773), // Light Shiny Gold
      Color(0xFFFFCC00), // Rich Gold
      Color(0xFFFFB200), // Deep Gold
      Color(0xFFFFD700), // Classic Gold
    ],
  );


  static Color getSolidFromGradient(LinearGradient gradient) {
    List<Color> colors = gradient.colors;

    // Initialize RGB components
    int r = 0, g = 0, b = 0;

    // Sum up all the colors in the gradient
    for (Color color in colors) {
      r += color.red;
      g += color.green;
      b += color.blue;
    }

    // Average the RGB values
    r = (r / colors.length).round();
    g = (g / colors.length).round();
    b = (b / colors.length).round();

    return Color.fromARGB(255, r, g, b); // Return average solid color
  }

  // Approximate solid color from golden gradient
  static final Color goldenSolid = getSolidFromGradient(golden);
}

