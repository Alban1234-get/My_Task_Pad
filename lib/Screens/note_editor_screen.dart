import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/checklist_item.dart';
import '../models/note_color.dart';
import '../services/note_repository.dart';

/// Écran d'édition ou de création de note (texte ou checklist) avec autosave.
class NoteEditorScreen extends StatefulWidget {
  final Note? existingNote;
  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> with WidgetsBindingObserver {
  final NoteRepository _repo = NoteRepository();
  late Note _note;
  late TextEditingController _titleCtrl;
  late TextEditingController _textCtrl;
  Timer? _debounceTimer;
  bool _hasUnsavedChanges = false;
  bool _isNewEmptyNote = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.existingNote != null) {
      _note = widget.existingNote!;
      if (_note.items != null) {
        _note.items = List<ChecklistItem>.from(_note.items!);
      }
    } else {
      _isNewEmptyNote = true;
      _note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titre: '',
        type: NoteType.texte,
        contenuTexte: '',
        couleur: NoteColor.jaune,
        dateCreation: DateTime.now(),
        dateModification: DateTime.now(),
      );
    }

    _titleCtrl = TextEditingController(text: _note.titre);
    _textCtrl = TextEditingController(text: _note.contenuTexte ?? '');

    _titleCtrl.addListener(_onChanged);
    _textCtrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveImmediately();
    _debounceTimer?.cancel();
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveImmediately();
    }
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

  void _onChanged() {
    _note.titre = _titleCtrl.text;
    if (_note.type == NoteType.texte) {
      _note.contenuTexte = _textCtrl.text;
    }
    _scheduleAutosave();
  }

  /// Planifie l'autosave avec debounce (700ms d'inactivité).
  void _scheduleAutosave() {
    _hasUnsavedChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), _saveImmediately);
  }

  /// Sauvegarde immédiate dans le repository.
  void _saveImmediately() {
    if (!_hasUnsavedChanges) return;

    if (_isNewEmptyNote &&
        _note.titre.trim().isEmpty &&
        ((_note.type == NoteType.texte && (_note.contenuTexte ?? '').trim().isEmpty) ||
         (_note.type == NoteType.checklist && (_note.items == null || _note.items!.isEmpty)))) {
      return;
    }

    _note.dateModification = DateTime.now();
    _repo.saveNote(_note);
    _hasUnsavedChanges = false;
    _isNewEmptyNote = false;
  }

  Future<void> _deleteNotePrompt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Voulez-vous vraiment supprimer cette note ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _debounceTimer?.cancel();
      _hasUnsavedChanges = false;
      await _repo.deleteNote(_note.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_note.type == NoteType.texte ? 'Note Texte' : 'Checklist'),
        actions: [
          if (widget.existingNote != null)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteNotePrompt),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(hintText: 'Titre', border: InputBorder.none),
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (_note.type == NoteType.texte)
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(hintText: 'Notez quelque chose...', border: InputBorder.none),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: _note.items?.length ?? 0,
                        // ignore: deprecated_member_use
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx -= 1;
                            final item = _note.items!.removeAt(oldIdx);
                            _note.items!.insert(newIdx, item);
                            _scheduleAutosave();
                          });
                        },
                        itemBuilder: (context, idx) {
                          final item = _note.items![idx];
                          return KeyedSubtree(
                            key: ValueKey(item),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item.coche,
                                  onChanged: (v) {
                                    setState(() {
                                      item.coche = v ?? false;
                                      _scheduleAutosave();
                                    });
                                  },
                                ),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.texte,
                                    decoration: const InputDecoration(hintText: 'Élément', border: InputBorder.none),
                                    onChanged: (v) {
                                      item.texte = v;
                                      _scheduleAutosave();
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _note.items!.removeAt(idx);
                                      _scheduleAutosave();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _note.items ??= [];
                          _note.items!.add(ChecklistItem(texte: ''));
                          _scheduleAutosave();
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un item'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: NoteColor.values.map((col) {
                  final isSel = _note.couleur == col;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _note.couleur = col;
                        _scheduleAutosave();
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: _getColor(col),
                        shape: BoxShape.circle,
                        border: Border.all(color: isSel ? Colors.black87 : Colors.grey.shade400, width: isSel ? 3 : 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

