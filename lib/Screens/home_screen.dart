import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_repository.dart';
import '../widgets/note_card.dart';
import '../widgets/search_bar_widget.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteRepository _repo = NoteRepository();
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = (_isSearching && _searchCtrl.text.isNotEmpty)
          ? _repo.searchNotes(_searchCtrl.text)
          : _repo.getAllNotes();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? SearchBarWidget(
                controller: _searchCtrl,
                onChanged: (_) => _loadNotes(),
              )
            : const Text('Mes Notes'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchCtrl.clear();
                } else {
                  _isSearching = true;
                }
                _loadNotes();
              });
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune note pour le moment', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: _notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
                ),
                itemBuilder: (context, i) {
                  final note = _notes[i];
                  return NoteCard(
                    note: note,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteEditorScreen(existingNote: note),
                        ),
                      );
                      _loadNotes();
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final chosenType = await showDialog<NoteType>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Créer une note'),
              content: const Text('Choisissez le type de note :'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, NoteType.texte),
                  child: const Text('Texte'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, NoteType.checklist),
                  child: const Text('Checklist'),
                ),
              ],
            ),
          );

          if (chosenType != null) {
            if (!context.mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(
                  existingNote: null,
                  initialType: chosenType,
                ),
              ),
            );
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
