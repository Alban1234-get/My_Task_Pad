import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_task_pad/main.dart';
import 'package:my_task_pad/models/checklist_item.dart';
import 'package:my_task_pad/models/note.dart';
import 'package:my_task_pad/models/note_color.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChecklistItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(NoteColorAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(NoteAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteTypeAdapter());
    await Hive.openBox('notes');
  });

  testWidgets('App loads HomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Mes Notes'), findsOneWidget);
  });
}

