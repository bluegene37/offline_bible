import 'package:flutter/material.dart';

class AppColors {
  // A curated, modern color palette
  static final Map<String, Color> themeColors = {
    'Black': Colors.black,
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Pink': Colors.pink,
    'Purple': Colors.purple,
    'Deep Purple': Colors.deepPurple,
    'Indigo': Colors.indigo,
    'Cyan': Colors.cyan,
    'Teal': Colors.teal,
    'Green': Colors.green,
    'Light Green': Colors.lightGreen,
    'Lime': Colors.lime,
    'Yellow': Colors.yellow,
    'Amber': Colors.amber,
    'Orange': Colors.orange,
    'Deep Orange': Colors.deepOrange,
    'Brown': Colors.brown,
    'Blue Grey': Colors.blueGrey,
    'Grey': Colors.grey,
  };

  static final Map<String, Color> themeColorShades = {
    'Black': Colors.grey.shade700,
    'Blue': Colors.blue.shade100,
    'Red': Colors.red.shade100,
    'Pink': Colors.pink.shade100,
    'Purple': Colors.purple.shade100,
    'Deep Purple': Colors.deepPurple.shade100,
    'Indigo': Colors.indigo.shade100,
    'Cyan': Colors.cyan.shade100,
    'Teal': Colors.teal.shade100,
    'Green': Colors.green.shade100,
    'Light Green': Colors.lightGreen.shade100,
    'Lime': Colors.lime.shade100,
    'Yellow': Colors.yellow.shade100,
    'Amber': Colors.amber.shade100,
    'Orange': Colors.orange.shade100,
    'Deep Orange': Colors.deepOrange.shade100,
    'Brown': Colors.brown.shade100,
    'Blue Grey': Colors.blueGrey.shade100,
    'Grey': Colors.grey.shade400,
  };

  static const List<Color> textColors = [
    Colors.white,
    Colors.black,
  ];

  // Highlight colors are now a subset of the main theme shades
  // Highlight colors: Premium Pastel Markers
  static final List<Color> highlightColors = [
    const Color(0xFFFFF9C4), // Pastel Yellow (Classic)
    const Color(0xFFC8E6C9), // Pastel Green
    const Color(0xFFBBDEFB), // Pastel Blue
    const Color(0xFFF8BBD0), // Pastel Pink
    const Color(0xFFE1BEE7), // Pastel Purple
    const Color(0xFFFFCCBC), // Pastel Deep Orange
    const Color(0xFFD7CCC8), // Pastel Brown
    const Color(0xFFB2DFDB), // Pastel Teal
    const Color(0xFFB2EBF2), // Pastel Cyan
    const Color(0xFFF0F4C3), // Pastel Lime
    const Color(0xFFC5CAE9), // Pastel Indigo
    const Color(0xFFFFCDD2), // Pastel Red
    const Color(0xFFFFECB3), // Pastel Amber
  ];
}
