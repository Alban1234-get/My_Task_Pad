import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/note_color.dart';
import '../services/note_repository.dart';
import '../theme/note_colors.dart';
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



  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
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
                  String preview = '';
                  if (note.type == NoteType.texte) {
                    preview = note.contenuTexte ?? '';
                  } else if (note.type == NoteType.checklist) {
                    final items = note.items ?? [];
                    final checked = items.where((it) => it.coche).length;
                    preview = '$checked/${items.length} items';
                  }

                  final textColor = note.couleur.onBackground;

                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteEditorScreen(existingNote: note),
                        ),
                      );
                      _loadNotes();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: note.couleur.background,
                        borderRadius: BorderRadius.circular(12),
                        border: note.couleur == NoteColor.blanc
                            ? Border.all(color: Colors.grey.shade300, width: 1)
                            : null,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.titre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              preview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.85)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              _formatDate(note.dateModification),
                              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  existingNote: Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    titre: '',
                    type: chosenType,
                    contenuTexte: chosenType == NoteType.texte ? '' : null,
                    items: chosenType == NoteType.checklist ? [] : null,
                    couleur: NoteColor.jaune,
                    dateCreation: DateTime.now(),
                    dateModification: DateTime.now(),
                  ),
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
