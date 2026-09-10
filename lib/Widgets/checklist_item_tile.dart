import 'package:flutter/material.dart';
import '../models/checklist_item.dart';

/// Widget représentant une ligne d'élément de checklist modifiable.
class ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onCheckChanged;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onDelete;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onCheckChanged,
    required this.onTextChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: item.coche,
          onChanged: onCheckChanged,
        ),
        Expanded(
          child: TextFormField(
            initialValue: item.texte,
            decoration: const InputDecoration(
              hintText: 'Items',
              border: InputBorder.none,
            ),
            onChanged: onTextChanged,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20, color: Colors.grey),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

