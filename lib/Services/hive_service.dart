import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/checklist_item.dart';
import '../models/note_color.dart';

/// Service centralisant l'initialisation de Hive, l'enregistrement des adapters et l'ouverture des boxes.
class HiveService {
  /// Initialise Hive, enregistre les 4 adaptateurs de modèles et ouvre la box "notes".
  static Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(ChecklistItemAdapter());
    Hive.registerAdapter(NoteColorAdapter());
    Hive.registerAdapter(NoteTypeAdapter());

    await Hive.openBox('notes');
  }
}

