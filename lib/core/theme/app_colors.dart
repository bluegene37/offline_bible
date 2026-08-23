import 'package:flutter/material.dart';

class AppColors {
  // A curated, modern color palette inspired by Apple Books / YouVersion
  static final Map<String, Color> themeColors = {
    'Sapphire': const Color(0xFF0F52BA),
    'Emerald': const Color(0xFF50C878),
    'Royal Amethyst': const Color(0xFF9966CC),
    'Sunset Amber': const Color(0xFFFFBF00),
    'Forest Teal': const Color(0xFF006D5B),
    'Crimson Rose': const Color(0xFFDC143C),
    'Terracotta': const Color(0xFFE2725B),
    'Midnight Slate': const Color(0xFF434B4D),
    'Deep Indigo': const Color(0xFF3F00FF),
    'Ocean Cyan': const Color(0xFF00B7EB),
    'Warm Coral': const Color(0xFFFF7F50),
    'Obsidian': const Color(0xFF242526),
  };

  // Pastel marker highlights
  static final List<Color> highlightColors = [
    const Color(0xFFFDE68A), // Butter Yellow
    const Color(0xFFA7F3D0), // Mint
    const Color(0xFFBAE6FD), // Soft Sky
    const Color(0xFFFECACA), // Coral Peach
    const Color(0xFFE9D5FF), // Lavender
    const Color(0xFFFBCFE8), // Rose
    const Color(0xFF99F6E4), // Jade
    const Color(0xFFA5F3FC), // Cyan
  ];

  /// Spoken names for [highlightColors], so the swatches are distinguishable
  /// to a screen reader instead of being eight identical unlabeled buttons.
  static const List<String> highlightColorNames = [
    'Yellow',
    'Mint',
    'Sky',
    'Peach',
    'Lavender',
    'Rose',
    'Jade',
    'Cyan',
  ];

  /// The reading surface. Deliberately independent of the accent colour: the
  /// page behind scripture should read as paper, not as a tinted UI panel.
  /// Warm off-white rather than the cool app surface, which is easier on the
  /// eye over long sessions.
  static const Color paperLight = Color(0xFFFBF9F4);
  static const Color paperDark = Color(0xFF121212);

  // Colors used for surface backgrounds
  static const Color lightSurface = Color(0xFFF9FAFB);
  static const Color darkSurface = Color(0xFF121212);

  // Background colors for the reader
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF000000);
  
  // App bar and navigation translucency
  static const Color lightTranslucent = Color(0xD9FFFFFF);
  static const Color darkTranslucent = Color(0xD9000000);
}
