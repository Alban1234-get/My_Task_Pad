// Classe Note avec ses propiétés 

import 'package:hive/hive.dart';
import 'checklist_item.dart';
import 'note_color.dart';

part 'note.g.dart';

@HiveType(typeId: 3)
enum NoteType { 
  @HiveField(0)
  texte, 
  @HiveField(1)
  checklist 
} // soit un texte soit une checklist

@HiveType(typeId: 2)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String titre;

  @HiveField(2)
  NoteType type;

  @HiveField(3)
  String? contenuTexte;

  @HiveField(4)
  List<ChecklistItem>? items;

  @HiveField(5)
  NoteColor couleur;

  @HiveField(6)
  DateTime dateCreation;

  @HiveField(7)
  DateTime dateModification;

  Note({
    required this.id,
    required this.titre,
    required this.type,
    this.contenuTexte,
    this.items,
    required this.couleur,
    required this.dateCreation,
    required this.dateModification,
  });
}
