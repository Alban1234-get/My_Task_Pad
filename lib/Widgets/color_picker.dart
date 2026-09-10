import 'package:flutter/material.dart';
import '../models/note_color.dart';
import '../theme/note_colors.dart';

/// Widget affichant un sélecteur horizontal de couleurs pour une note.
class ColorPicker extends StatelessWidget {
  final NoteColor selectedColor;
  final ValueChanged<NoteColor> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: NoteColor.values.map((col) {
          final isSel = selectedColor == col;
          return GestureDetector(
            onTap: () => onColorSelected(col),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: col.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSel ? Colors.black87 : Colors.grey.shade400,
                  width: isSel ? 3 : 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

