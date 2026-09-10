import 'package:flutter/material.dart';
import '../models/note_color.dart';

/// Extension centralisant les couleurs de fond et de texte associées à chaque NoteColor.
extension NoteColorX on NoteColor {
  /// Retourne la couleur de fond associée à la valeur de NoteColor.
  Color get background {
    switch (this) {
      case NoteColor.jaune:
        return const Color(0xFFFFEB3B); // Note: exact hex is FFEB3B
      case NoteColor.orange:
        return const Color(0xFFFF9800);
      case NoteColor.rose:
        return const Color(0xFFE91E63);
      case NoteColor.violet:
        return const Color(0xFF9C27B0);
      case NoteColor.bleu:
        return const Color(0xFF1E88E5);
      case NoteColor.vertClair:
        return const Color(0xFF8BC34A);
      case NoteColor.vertFonce:
        return const Color(0xFF2E7D32);
      case NoteColor.gris:
        return const Color(0xFF757575);
      case NoteColor.blanc:
        return const Color(0xFFFAFAFA);
    }
  }

  /// Retourne la couleur de texte (contraste correct) associée à la valeur de NoteColor.
  Color get onBackground {
    switch (this) {
      case NoteColor.jaune:
      case NoteColor.orange:
      case NoteColor.vertClair:
      case NoteColor.blanc:
        return Colors.black87;
      case NoteColor.rose:
      case NoteColor.violet:
      case NoteColor.bleu:
      case NoteColor.vertFonce:
      case NoteColor.gris:
        return Colors.white;
    }
  }
}
