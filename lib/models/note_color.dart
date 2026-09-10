import 'package:hive/hive.dart';

part 'note_color.g.dart';

/*
Un enum ou une classe qui centralise la palette de couleurs(jaune, orange, rose..) 
avec leurs codes hexadécimaux, pour éviter de disperser des couleurs 
en dur partout dans le code.
*/

@HiveType(typeId: 1)
enum NoteColor { // enum pour éviter les faute de frappe avec strings 
  @HiveField(0)
  jaune, // "jaune" ou "Jaune"
  @HiveField(1)
  orange,
  @HiveField(2)
  rose,
  @HiveField(3)
  violet,
  @HiveField(4)
  bleu,
  @HiveField(5)
  vertClair,
  @HiveField(6)
  vertFonce,
  @HiveField(7)
  gris,
  @HiveField(8)
  blanc,
}
