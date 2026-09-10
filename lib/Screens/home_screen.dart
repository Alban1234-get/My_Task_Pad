import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/note_color.dart';
import '../services/note_repository.dart';
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

  Color _getColor(NoteColor c) {
    switch (c) {
      case NoteColor.jaune: return const Color(0xFFFFEB3B);
      case NoteColor.orange: return const Color(0xFFFFB74D);
      case NoteColor.rose: return const Color(0xFFF48FB1);
      case NoteColor.violet: return const Color(0xFFCE93D8);
      case NoteColor.bleu: return const Color(0xFF90CAF9);
      case NoteColor.vertClair: return const Color(0xFFC5E1A5);
      case NoteColor.vertFonce: return const Color(0xFFA5D6A7);
      case NoteColor.gris: return const Color(0xFFE0E0E0);
      case NoteColor.blanc: return const Color(0xFFFFFFFF);
    }
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
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 18),
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
                        color: _getColor(note.couleur),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Expanded(child: Text(preview, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(_formatDate(note.dateModification), style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
