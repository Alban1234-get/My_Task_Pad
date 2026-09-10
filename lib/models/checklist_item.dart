import 'package:hive/hive.dart';

part 'checklist_item.g.dart';

/*
Une Classe (texte + booléen coché), utilisée comme sous-objet dans une Note de type checklist.
*/

@HiveType(typeId: 0)
class ChecklistItem {
  @HiveField(0)
  String texte;

  @HiveField(1)
  bool coche;

  ChecklistItem({
    required this.texte, // obligation de fournir un thème à la création
    this.coche = false, // pas coché pas défaut
  });
}
