import 'package:flutter/material.dart';

/// Classe centralisant le thème global de l'application.
class AppTheme {
  /// Retourne le ThemeData clair de l'application basé sur Material Design 3.
  static ThemeData light() {
    // Génération du ColorScheme à partir d'une couleur seed neutre (bleu-gris)
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF546E7A),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Couleur de fond générale de l'application (très claire)
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),

      // Thème de l'AppBar (sobre avec un elevation à 0)
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),

      // Thème du FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      // Thème des cartes avec une élévation et des coins arrondis
      cardTheme: CardThemeData(
        elevation: 3.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
