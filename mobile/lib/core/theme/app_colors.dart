import 'package:flutter/material.dart';

class AppColors {
  // Primary Orange (Hydrau-Link theme)
  static const Color primary = Color(0xFFE8670A);
  static const Color primaryLight = Color(0xFFFF8534);
  static const Color primaryDark = Color(0xFFC4540A);
  static const Color primarySurface = Color(0xFFFFF0E6);
  static const Color primaryBorder = Color(0xFFFFCDA8);

  // Navy (header / top section)
  static const Color navy = Color(0xFF1E2D4A);
  static const Color navyMid = Color(0xFF2A3F60);

  // Semantic
  static const Color green = Color(0xFF059669);
  static const Color greenSurface = Color(0xFFEDFAF4);
  static const Color amber = Color(0xFFD97706);
  static const Color amberSurface = Color(0xFFFFFBEA);
  static const Color red = Color(0xFFDC2626);
  static const Color redSurface = Color(0xFFFFF0F0);
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetSurface = Color(0xFFF3F0FE);
  static const Color blue = Color(0xFF2563EB);
  static const Color blueSurface = Color(0xFFEBF3FE);
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkSurface = Color(0xFFFFF0F7);

  // Neutral
  static const Color ink = Color(0xFF111827);
  static const Color slate600 = Color(0xFF374151);
  static const Color slate500 = Color(0xFF6B7280);
  static const Color slate400 = Color(0xFF9CA3AF);
  static const Color slate300 = Color(0xFFD1D5DB);
  static const Color line = Color(0xFFECEEF2);
  static const Color line2 = Color(0xFFF7F8FA);
  static const Color bg = Color(0xFFF7F8FA);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLight, primary, primaryDark],
  );

  // Navy gradient (for header)
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy, navyMid],
  );

  // Shadows
  static List<BoxShadow> shadowCard = const [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static List<BoxShadow> shadowSoft = const [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowPrimary = const [
    BoxShadow(
      color: Color(0x52E8670A),
      blurRadius: 22,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [blueSurface, blue],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'orange': [primarySurface, primary],
    'pink': [pinkSurface, pink],
    'slate': [bg, slate500],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['orange']!;
}
