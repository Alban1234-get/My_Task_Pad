// Classe Note avec ses propiétés 

import 'package:my_task_pad/Models/checklis_item.dart';
import 'note_color.dart';

enum NoteType { texte, checklist } // soit un texte soit une checklist

class Note {
  String id;
  String titre;
  NoteType type;
  String? contenuTexte;
  List<ChecklisItem>? items;
  NoteColor couleur;
  DateTime dateCreation;
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