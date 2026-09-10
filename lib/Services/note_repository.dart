import 'package:hive/hive.dart';
import '../models/note.dart';

/// Repository centralisant tous les accès à la box Hive "notes".
class NoteRepository {
  /// Récupère la box Hive "notes".
  Box get _notesBox => Hive.box('notes');

  /// Récupère toutes les notes de la box, triées par dateModification 
  /// décroissante (les plus récentes en premier).
  List<Note> getAllNotes() {
    final notes = _notesBox.values.whereType<Note>().toList();
    notes.sort((a, b) => b.dateModification.compareTo(a.dateModification));
    return notes;
  }

  /// Sauvegarde ou met à jour une note dans la box, en utilisant note.id comme clé.
  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  /// Supprime une note par son id.
  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  /// Récupère une seule note par son id, retourne null si elle n'existe pas.
  Note? getNoteById(String id) {
    return _notesBox.get(id) as Note?;
  }

  /// Filtre les notes dont le titre OU le contenuTexte contient la requête 
  /// (insensible à la casse), pour une note de type texte uniquement.
  List<Note> searchNotes(String query) {
    final box = Hive.box('notes');
    final lowerQuery = query.toLowerCase();
    return box.values.cast<Note>().where((note) {
      if (note.titre.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      if (note.type == NoteType.texte) {
        return note.contenuTexte?.toLowerCase().contains(lowerQuery) ?? false;
      }
      if (note.type == NoteType.checklist) {
        final items = note.items ?? [];
        return items.any((items) => items.texte.toLowerCase().contains(lowerQuery));
      }
      return false;
    }).toList();
    /*
    return getAllNotes().where((note) {
      if (note.type != NoteType.texte) return false;
      final matchTitle = note.titre.toLowerCase().contains(lowerQuery);
      final matchContent = note.contenuTexte?.toLowerCase().contains(lowerQuery) ?? false;
      return matchTitle || matchContent;
    }).toList();*/
  }
}

