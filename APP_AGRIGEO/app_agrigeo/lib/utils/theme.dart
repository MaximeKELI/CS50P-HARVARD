import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs de base
  static const Color primaryGreen = Color(0xFF2E7D32); // Vert forêt
  static const Color earthBrown = Color(0xFF6D4C41); // Marron terreux
  static const Color sunAmber = Color(0xFFFFA000); // Orange soleil
  static const Color errorRed = Color(0xFFD32F2F); // Rouge d'erreur
  static const Color soilBeige = Color(0xFFFFF3E0); // Beige sol

  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: earthBrown,
      tertiary: sunAmber,
      error: errorRed,
      background: soilBeige,
    ),
    textTheme: _agricultureTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cropCardTheme,
  );

  // Thème sombre
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: earthBrown,
      tertiary: sunAmber,
      error: errorRed,
      background: Color(0xFF121212),
    ),
    textTheme: _agricultureTextTheme.apply(
      displayColor: Colors.white,
      bodyColor: Colors.white70,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: _cropCardTheme.copyWith(
      color: const Color(0xFF1E1E1E),
    ),
  );

  // TextTheme personnalisé
  static const TextTheme _agricultureTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.25,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: primaryGreen,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  // Style des boutons élevés
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: _agricultureTextTheme.labelLarge?.copyWith(color: Colors.white),
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
  );

  // Style des boutons outlined
  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: primaryGreen),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
    ),
  );

  // Style des champs de formulaire
  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: sunAmber),
    ),
    floatingLabelStyle: TextStyle(color: sunAmber),
  );

  // Style des cartes de cultures
  static const CardTheme _cropCardTheme = CardTheme(
    elevation: 2,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  // Méthode pour le style des statuts de culture
  static TextStyle cropStatusStyle(CropStatus status) {
    switch (status) {
      case CropStatus.healthy:
        return const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold);
      case CropStatus.warning:
        return const TextStyle(color: sunAmber, fontWeight: FontWeight.bold);
      case CropStatus.critical:
        return const TextStyle(color: errorRed, fontWeight: FontWeight.bold);
    }
  }
}

// Enum pour le statut des cultures
enum CropStatus { healthy, warning, critical }
