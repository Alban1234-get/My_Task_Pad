/*
Une Classe (texte + booléen coché), utilisée comme sous-objet dans une Note de type checklist.
*/

class ChecklisItem {
  String texte;
  bool coche;

  ChecklisItem({
    required this.texte, // obligation de fournir un thème à la création
    this.coche = false, // pas coché pas défaut
  });
}