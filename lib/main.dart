import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';
import 'models/checklist_item.dart';
import 'models/note_color.dart';
import 'package:my_task_pad/Screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ChecklistItemAdapter());
  Hive.registerAdapter(NoteColorAdapter());
  Hive.registerAdapter(NoteTypeAdapter());

  await Hive.openBox('notes');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Bloc Note',
      theme: AppTheme.light(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
