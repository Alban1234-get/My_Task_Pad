// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 2;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      id: fields[0] as String,
      titre: fields[1] as String,
      type: fields[2] as NoteType,
      contenuTexte: fields[3] as String?,
      items: (fields[4] as List?)?.cast<ChecklistItem>(),
      couleur: fields[5] as NoteColor,
      dateCreation: fields[6] as DateTime,
      dateModification: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.contenuTexte)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.couleur)
      ..writeByte(6)
      ..write(obj.dateCreation)
      ..writeByte(7)
      ..write(obj.dateModification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteTypeAdapter extends TypeAdapter<NoteType> {
  @override
  final int typeId = 3;

  @override
  NoteType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteType.texte;
      case 1:
        return NoteType.checklist;
      default:
        return NoteType.texte;
    }
  }

  @override
  void write(BinaryWriter writer, NoteType obj) {
    switch (obj) {
      case NoteType.texte:
        writer.writeByte(0);
        break;
      case NoteType.checklist:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
