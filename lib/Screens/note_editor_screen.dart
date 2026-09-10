import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/checklist_item.dart';
import '../models/note_color.dart';
import '../services/autosave_service.dart';
import '../services/note_repository.dart';
import '../widgets/checklist_item_tile.dart';
import '../widgets/color_picker.dart';

/// Écran d'édition ou de création de note (texte ou checklist) avec autosave.
class NoteEditorScreen extends StatefulWidget {
  final Note? existingNote;
  final NoteType initialType;

  const NoteEditorScreen({
    super.key,
    this.existingNote,
    this.initialType = NoteType.texte,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> with WidgetsBindingObserver {
  final NoteRepository _repo = NoteRepository();
  final AutosaveService _autosaveService = AutosaveService();
  late Note _note;
  late TextEditingController _titleCtrl;
  late TextEditingController _textCtrl;
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
        type: widget.initialType,
        contenuTexte: widget.initialType == NoteType.texte ? '' : null,
        items: widget.initialType == NoteType.checklist ? [] : null,
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
    _autosaveService.saveNow(_saveImmediately);
    _autosaveService.dispose();
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _autosaveService.saveNow(_saveImmediately);
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
    _autosaveService.schedule(_saveImmediately);
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
      _autosaveService.cancel();
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
                            child: ChecklistItemTile(
                              item: item,
                              onCheckChanged: (v) {
                                setState(() {
                                  item.coche = v ?? false;
                                  _scheduleAutosave();
                                });
                              },
                              onTextChanged: (v) {
                                item.texte = v;
                                _scheduleAutosave();
                              },
                              onDelete: () {
                                setState(() {
                                  _note.items!.removeAt(idx);
                                  _scheduleAutosave();
                                });
                              },
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
            ColorPicker(
              selectedColor: _note.couleur,
              onColorSelected: (col) {
                setState(() {
                  _note.couleur = col;
                  _scheduleAutosave();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

